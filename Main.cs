using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using LSPD_First_Response.Mod.Callouts;
using LSPD_First_Response.Mod.API;
using Rage;
using Rage.Native;

namespace ConvoyBreakerCallout
{
    [CalloutInfo("ConvoyBreaker", CalloutProbability.Medium)]
    public class ConvoyBreakerCallout : Callout
    {
        #region Variables
        
        // Mission State
        private bool calloutAccepted = false;
        private MissionPhase currentPhase = MissionPhase.Intercept;
        private bool convoyIntercepted = false;
        private bool stealthMode = true;
        private bool alarmsTriggered = false;
        private bool generatorDestroyed = false;
        private bool leaderCaptured = false;
        
        // Locations
        private Vector3 convoySpawnPoint;
        private Vector3 convoyDestination;
        private Vector3 ambushPoint;
        private Vector3 cartelBaseLocation;
        private Vector3 heliInsertionPoint;
        private Vector3 extractionPoint;
        
        // Convoy Vehicles
        private Vehicle leadSUV;
        private Vehicle cargoTruck1;
        private Vehicle cargoTruck2;
        private Vehicle rearSUV;
        private List<Vehicle> convoyVehicles = new List<Vehicle>();
        private List<Vehicle> reinforcementVehicles = new List<Vehicle>();
        
        // NPCs
        private List<Ped> cartelMembers = new List<Ped>();
        private List<Ped> ghostOperatives = new List<Ped>();
        private List<Ped> baseGuards = new List<Ped>();
        private Ped cartelLeader;
        private Ped ghostSniper;
        
        // Helicopter and Support
        private Vehicle annihilator2;
        private Ped heliPilot;
        private bool ghostTeamDeployed = false;
        private bool extractionCalled = false;
        
        // Blips and UI
        private Blip convoyBlip;
        private Blip ambushBlip;
        private Blip baseBlip;
        private Blip extractionBlip;
        private List<Blip> operativeBlips = new List<Blip>();
        
        // Base Objects
        private List<Rage.Object> baseLights = new List<Rage.Object>();
        private Rage.Object generator;
        private List<Rage.Object> guardTowers = new List<Rage.Object>();
        
        // Timers and Counters
        private DateTime missionStartTime;
        private DateTime lastRadioChatter;
        private int enemiesNeutralized = 0;
        private int civiliansAlerted = 0;
        
        #endregion

        #region Enums
        
        private enum MissionPhase
        {
            Intercept,
            ConvoyEngagement,
            BaseInfiltration,
            LeaderObjective,
            Extraction,
            Complete
        }
        
        private enum InfiltrationMethod
        {
            Ghost,      // Full stealth with blackout
            Panther,    // Aggressive stealth
            Assault     // Loud and fast
        }
        
        #endregion

        #region Callout Initialization

        public override bool OnBeforeCalloutDisplayed()
        {
            // Find suitable spawn points
            convoySpawnPoint = World.GetNextPositionOnStreet(Game.LocalPlayer.Character.Position.Around(800f));
            convoyDestination = World.GetNextPositionOnStreet(convoySpawnPoint.Around(1500f));
            ambushPoint = World.GetNextPositionOnStreet(Vector3.Lerp(convoySpawnPoint, convoyDestination, 0.4f).Around(200f));
            cartelBaseLocation = World.GetNextPositionOnStreet(convoyDestination.Around(300f));
            heliInsertionPoint = ambushPoint + new Vector3(0f, 0f, 50f);
            extractionPoint = ambushPoint.Around(100f);

            // Set callout info
            ShowCalloutAreaBlipBeforeAccepting(ambushPoint, 75f);
            CalloutMessage = "[CLASSIFIED] Operation: Convoy Breaker";
            CalloutPosition = ambushPoint;
            
            // Play tactical dispatch audio
            Functions.PlayScannerAudioUsingPosition("ATTENTION_ALL_UNITS WE_HAVE CRIME_GANG_RELATED IN_OR_ON_POSITION", ambushPoint);
            
            return base.OnBeforeCalloutDisplayed();
        }

        public override bool OnCalloutAccepted()
        {
            calloutAccepted = true;
            missionStartTime = DateTime.Now;
            currentPhase = MissionPhase.Intercept;
            
            // Mission briefing
            DisplayTacticalBriefing();
            
            // Setup mission elements
            SetupConvoy();
            SetupAmbushPoint();
            DeployGhostTeam();
            
            Game.LogTrivial("ConvoyBreakerCallout: Mission initiated - Operation Convoy Breaker");
            return base.OnCalloutAccepted();
        }

        #endregion

        #region Mission Setup

        private void DisplayTacticalBriefing()
        {
            Game.DisplayNotification("web_lossantospolicedept", "web_lossantospolicedept",
                "~r~CLASSIFIED OPERATION", "~w~CONVOY BREAKER",
                "~w~Shadow Unit, satellite confirms cartel convoy moving heavy weapons. " +
                "~y~Suppressed weapons only. ~w~Ghost team will support from Annihilator 2. " +
                "~r~Intercept before they reach the stronghold.");
                
            Game.DisplayHelp("Press ~INPUT_CONTEXT~ to coordinate with Ghost team | Press ~INPUT_COVER~ for tactical options", 8000);
        }

        private void SetupConvoy()
        {
            // Lead SUV - Scouts
            leadSUV = new Vehicle("GRANGER2", convoySpawnPoint);
            leadSUV.IsPersistent = true;
            leadSUV.PrimaryColor = Color.Black;
            leadSUV.SecondaryColor = Color.Black;
            
            // Cargo Trucks
            cargoTruck1 = new Vehicle("MULE3", convoySpawnPoint + Vector3.RelativeBack * 15f);
            cargoTruck1.IsPersistent = true;
            cargoTruck1.PrimaryColor = Color.DarkGray;
            
            cargoTruck2 = new Vehicle("MULE3", convoySpawnPoint + Vector3.RelativeBack * 30f);
            cargoTruck2.IsPersistent = true;
            cargoTruck2.PrimaryColor = Color.DarkGray;
            
            // Rear SUV - Heavy escort
            rearSUV = new Vehicle("GRANGER2", convoySpawnPoint + Vector3.RelativeBack * 45f);
            rearSUV.IsPersistent = true;
            rearSUV.PrimaryColor = Color.Black;
            rearSUV.SecondaryColor = Color.Black;
            
            convoyVehicles.AddRange(new[] { leadSUV, cargoTruck1, cargoTruck2, rearSUV });
            
            // Populate vehicles with cartel members
            PopulateConvoyWithCartel();
            
            // Setup convoy AI behavior
            SetupConvoyAI();
            
            // Create convoy blip
            convoyBlip = leadSUV.AttachBlip();
            convoyBlip.Color = Color.Red;
            convoyBlip.Name = "Cartel Convoy";
            convoyBlip.EnableRoute(Color.Red);
        }

        private void PopulateConvoyWithCartel()
        {
            // Lead SUV - 2 scouts with rifles
            var leadDriver = leadSUV.CreateRandomDriver();
            var leadGunner = leadSUV.CreateRandomPedOnSeat(0); // 0 = Passenger seat
            
            leadDriver.Inventory.GiveNewWeapon("WEAPON_ASSAULTRIFLE", 200, true);
            leadGunner.Inventory.GiveNewWeapon("WEAPON_CARBINERIFLE", 200, true);
            
            cartelMembers.AddRange(new[] { leadDriver, leadGunner });
            
            // Cargo trucks - drivers only
            var truck1Driver = cargoTruck1.CreateRandomDriver();
            var truck2Driver = cargoTruck2.CreateRandomDriver();
            
            truck1Driver.Inventory.GiveNewWeapon("WEAPON_MICROSMG", 150, true);
            truck2Driver.Inventory.GiveNewWeapon("WEAPON_MICROSMG", 150, true);
            
            cartelMembers.AddRange(new[] { truck1Driver, truck2Driver });
            
            // Rear SUV - heavily armed escort
            var rearDriver = rearSUV.CreateRandomDriver();
            var rearGunner = rearSUV.CreateRandomPedOnSeat(0); // 0 = Passenger seat
            var rearEnforcer = rearSUV.CreateRandomPedOnSeat(1); // 1 = Left rear seat
            
            rearDriver.Inventory.GiveNewWeapon("WEAPON_ASSAULTRIFLE", 200, true);
            rearGunner.Inventory.GiveNewWeapon("WEAPON_MG", 300, true);  // Light machine gun
            rearEnforcer.Inventory.GiveNewWeapon("WEAPON_PUMPSHOTGUN", 100, true);
            
            cartelMembers.AddRange(new[] { rearDriver, rearGunner, rearEnforcer });
            
            // Configure all cartel members
            foreach (var member in cartelMembers)
            {
                member.IsPersistent = true;
                member.BlockPermanentEvents = true;
                member.RelationshipGroup = "HATES_PLAYER";
                member.Accuracy = 75;
                member.MaxHealth = 150;
                member.Health = 150;
            }
        }

        private void SetupConvoyAI()
        {
            // Lead vehicle drives to destination
            var leadTask = leadSUV.Driver.Tasks.DriveToPosition(convoyDestination, 25f, VehicleDrivingFlags.Normal);
            leadTask.WaitForCompletion(1000);
            
            // Other vehicles follow in formation
            cargoTruck1.Driver.Tasks.FollowNavigationMeshToPosition(convoyDestination, 0f, 20f);
            cargoTruck2.Driver.Tasks.FollowNavigationMeshToPosition(convoyDestination, 0f, 20f);
            rearSUV.Driver.Tasks.FollowNavigationMeshToPosition(convoyDestination, 0f, 20f);
        }

        private void SetupAmbushPoint()
        {
            ambushBlip = new Blip(ambushPoint);
            ambushBlip.Color = Color.Yellow;
            ambushBlip.Name = "Ambush Point";
            ambushBlip.Sprite = BlipSprite.Enemy;
            
            Game.DisplayNotification("~y~Ambush point marked. ~w~Position yourself for convoy interception.");
        }

        private void DeployGhostTeam()
        {
            GameFiber.StartNew(() =>
            {
                // Spawn Annihilator 2 helicopter
                annihilator2 = new Vehicle("ANNIHILATOR2", heliInsertionPoint);
                annihilator2.IsPersistent = true;
                annihilator2.PrimaryColor = Color.Black;
                annihilator2.SecondaryColor = Color.Black;
                annihilator2.IsEngineOn = true;
                
                // Pilot
                heliPilot = annihilator2.CreateRandomDriver();
                heliPilot.IsPersistent = true;
                heliPilot.BlockPermanentEvents = true;
                
                // Hover at insertion point
                annihilator2.Driver.Tasks.Clear();
                
                GameFiber.Sleep(3000);
                
                // Deploy Ghost operatives
                SpawnGhostOperatives();
                
                GameFiber.Sleep(2000);
                
                // Radio chatter
                PlayRadioChatter("Ghost Lead", "Ghost team on station. Awaiting your signal, Shadow Unit.");
                
                ghostTeamDeployed = true;
            });
        }

        private void SpawnGhostOperatives()
        {
            Vector3[] insertionPoints = new Vector3[]
            {
                ambushPoint + Vector3.RelativeLeft * 20f,
                ambushPoint + Vector3.RelativeRight * 20f,
                ambushPoint + Vector3.RelativeFront * 15f,
                ambushPoint + Vector3.RelativeBack * 15f
            };
            
            for (int i = 0; i < 4; i++)
            {
                var operative = new Ped("S_M_Y_BLACKOPS_01", insertionPoints[i], 0f);
                operative.IsPersistent = true;
                operative.BlockPermanentEvents = true;
                operative.RelationshipGroup = "COP";
                operative.Accuracy = 90;
                operative.MaxHealth = 200;
                operative.Health = 200;
                
                // Suppressed weapons
                if (i == 0) // Sniper
                {
                    operative.Inventory.GiveNewWeapon("WEAPON_SNIPERRIFLE", 50, true);
                    ghostSniper = operative;
                    
                    // Position sniper on elevated position
                    var nearbyProps = World.GetAllProps().Where(p => Vector3.Distance(p.Position, operative.Position) < 50f).ToArray();
                    if (nearbyProps.Length > 0)
                    {
                        operative.Position = nearbyProps[0].Position + Vector3.WorldUp * 10f;
                    }
                }
                else
                {
                    operative.Inventory.GiveNewWeapon("WEAPON_CARBINERIFLE", 200, true);
                    operative.Inventory.GiveNewWeapon("WEAPON_COMBATPISTOL", 100, false);
                }
                
                ghostOperatives.Add(operative);
                
                // Create operative blip
                var opBlip = operative.AttachBlip();
                opBlip.Color = Color.Blue;
                opBlip.Name = $"Ghost {i + 1}";
                opBlip.Sprite = BlipSprite.Friend;
                operativeBlips.Add(opBlip);
                
                // Initial cover behavior
                operative.Tasks.TakeCoverFrom(convoySpawnPoint, -1);
            }
        }

        #endregion

        #region Main Process Loop

        public override void Process()
        {
            if (!calloutAccepted)
                return;
                
            // Check for end conditions
            if (Game.IsKeyDown(Keys.End))
            {
                End();
                return;
            }
            
            // Process based on current phase
            switch (currentPhase)
            {
                case MissionPhase.Intercept:
                    ProcessInterceptPhase();
                    break;
                case MissionPhase.ConvoyEngagement:
                    ProcessConvoyEngagement();
                    break;
                case MissionPhase.BaseInfiltration:
                    ProcessBaseInfiltration();
                    break;
                case MissionPhase.LeaderObjective:
                    ProcessLeaderObjective();
                    break;
                case MissionPhase.Extraction:
                    ProcessExtraction();
                    break;
                case MissionPhase.Complete:
                    CompleteMission();
                    break;
            }
            
            // Handle tactical controls
            HandleTacticalControls();
            
            // Update UI
            UpdateMissionUI();
            
            base.Process();
        }

        private void ProcessInterceptPhase()
        {
            // Check if convoy is near ambush point
            if (leadSUV.Exists() && Vector3.Distance(leadSUV.Position, ambushPoint) < 100f)
            {
                if (!convoyIntercepted)
                {
                    Game.DisplayNotification("~r~CONVOY APPROACHING! ~w~Engage now or they'll reach the base!");
                    PlayRadioChatter("Ghost Lead", "Convoy in sight. Weapons free on your command.");
                }
            }
            
            // Check if convoy reaches destination (failure condition)
            if (leadSUV.Exists() && Vector3.Distance(leadSUV.Position, convoyDestination) < 150f)
            {
                ConvoyReachedBase();
            }
            
            // Check for player engagement
            if (IsConvoyUnderAttack())
            {
                convoyIntercepted = true;
                currentPhase = MissionPhase.ConvoyEngagement;
                PlayRadioChatter("Ghost Lead", "Engaging! All callsigns, weapons free!");
                
                // Ghost team engages
                EngageGhostTeam();
            }
        }

        private void ProcessConvoyEngagement()
        {
            // Check if all convoy members are neutralized
            int aliveCartelMembers = cartelMembers.Count(c => c.Exists() && c.IsAlive);
            
            if (aliveCartelMembers == 0)
            {
                // Success - convoy neutralized
                ConvoyNeutralized();
            }
            else if (stealthMode && civiliansAlerted > 2)
            {
                // Stealth compromised
                stealthMode = false;
                Game.DisplayNotification("~r~STEALTH COMPROMISED! ~w~Civilians alerted authorities!");
                PlayRadioChatter("Ghost Lead", "We're blown! Switch to assault protocol!");
            }
        }

        private void ProcessBaseInfiltration()
        {
            // This phase only triggers if convoy escaped
            // Handle base infiltration mechanics here
            
            if (!alarmsTriggered && IsPlayerDetected())
            {
                TriggerBaseAlarms();
            }
            
            // Check for generator destruction
            if (generator != null && generator.Exists() && generator.HasBeenDamagedBy(Game.LocalPlayer.Character))
            {
                DestroyGenerator();
            }
        }

        private void ProcessLeaderObjective()
        {
            if (cartelLeader != null && cartelLeader.Exists())
            {
                if (!cartelLeader.IsAlive)
                {
                    // Leader eliminated
                    PlayRadioChatter("Ghost Lead", "Target down. Partial success.");
                    currentPhase = MissionPhase.Extraction;
                }
                else if (cartelLeader.IsCuffed)
                {
                    // Leader captured
                    leaderCaptured = true;
                    PlayRadioChatter("Ghost Lead", "Target secured! Excellent work, Shadow Unit.");
                    currentPhase = MissionPhase.Extraction;
                }
            }
        }

        private void ProcessExtraction()
        {
            if (!extractionCalled)
            {
                CallExtraction();
                extractionCalled = true;
            }
            
            // Check if player reaches extraction point
            if (Vector3.Distance(Game.LocalPlayer.Character.Position, extractionPoint) < 10f)
            {
                currentPhase = MissionPhase.Complete;
            }
        }

        #endregion

        #region Mission Events

        private void ConvoyReachedBase()
        {
            Game.DisplayNotification("~r~CONVOY REACHED BASE! ~w~Initiating base infiltration protocol.");
            PlayRadioChatter("Handler", "Shadow Unit, convoy has reached the compound. Switch to infiltration mode.");
            
            SetupCartelBase();
            currentPhase = MissionPhase.BaseInfiltration;
            
            // Remove convoy blips, add base blip
            if (convoyBlip.Exists()) convoyBlip.Delete();
            baseBlip = new Blip(cartelBaseLocation);
            baseBlip.Color = Color.Red;
            baseBlip.Name = "Cartel Stronghold";
            baseBlip.Sprite = BlipSprite.Enemy;
        }

        private void ConvoyNeutralized()
        {
            Game.DisplayNotification("~g~CONVOY NEUTRALIZED! ~w~Securing contraband...");
            PlayRadioChatter("Ghost Lead", "Convoy down! Securing cargo for extraction.");
            
            // Success state
            currentPhase = MissionPhase.Extraction;
            
            // Clean up convoy blips
            if (convoyBlip.Exists()) convoyBlip.Delete();
            
            // Award points for stealth
            if (stealthMode)
            {
                Game.DisplayNotification("~g~STEALTH BONUS! ~w~Operation completed without detection.");
            }
        }

        private void SetupCartelBase()
        {
            GameFiber.StartNew(() =>
            {
                // Create base perimeter
                Vector3[] guardPositions = new Vector3[]
                {
                    cartelBaseLocation + Vector3.RelativeFront * 30f,
                    cartelBaseLocation + Vector3.RelativeBack * 30f,
                    cartelBaseLocation + Vector3.RelativeLeft * 30f,
                    cartelBaseLocation + Vector3.RelativeRight * 30f
                };
                
                // Spawn base guards
                for (int i = 0; i < guardPositions.Length; i++)
                {
                    var guard = new Ped("G_M_Y_MexGang_01", guardPositions[i], 0f);
                    guard.IsPersistent = true;
                    guard.BlockPermanentEvents = true;
                    guard.RelationshipGroup = "HATES_PLAYER";
                    guard.Accuracy = 80;
                    
                    if (i < 2) // Snipers in towers
                    {
                        guard.Inventory.GiveNewWeapon("WEAPON_SNIPERRIFLE", 100, true);
                        guard.Position = guard.Position + Vector3.WorldUp * 15f; // Elevated position
                    }
                    else
                    {
                        guard.Inventory.GiveNewWeapon("WEAPON_ASSAULTRIFLE", 200, true);
                    }
                    
                    guard.Tasks.StandStill(-1);
                    baseGuards.Add(guard);
                }
                
                // Spawn cartel leader in safehouse
                cartelLeader = new Ped("G_M_Y_MexBoss_01", cartelBaseLocation, 0f);
                cartelLeader.IsPersistent = true;
                cartelLeader.BlockPermanentEvents = true;
                cartelLeader.RelationshipGroup = "HATES_PLAYER";
                cartelLeader.Accuracy = 95;
                cartelLeader.MaxHealth = 300;
                cartelLeader.Health = 300;
                cartelLeader.Inventory.GiveNewWeapon("WEAPON_PISTOL50", 100, true);
                
                // Create generator (can be destroyed for blackout)
                generator = new Rage.Object("prop_generator_03", cartelBaseLocation + Vector3.RelativeBack * 20f);
                generator.IsPersistent = true;
            });
        }

        private void DestroyGenerator()
        {
            if (generatorDestroyed) return;
            
            generatorDestroyed = true;
            Game.DisplayNotification("~g~GENERATOR DESTROYED! ~w~Compound in blackout - NVG advantage!");
            PlayRadioChatter("Ghost Lead", "Lights out! Switch to night vision, we own the dark now.");
            
            // Create blackout effect
            World.Weather = Rage.Weather.ExtraSunny; // Ensure it's not already dark
            NativeFunction.Natives.SET_ARTIFICIAL_LIGHTS_STATE(false);
            
            GameFiber.StartNew(() =>
            {
                GameFiber.Sleep(30000); // 30 second blackout
                NativeFunction.Natives.SET_ARTIFICIAL_LIGHTS_STATE(true);
                Game.DisplayNotification("~y~Emergency power restored at compound.");
            });
        }

        private void TriggerBaseAlarms()
        {
            alarmsTriggered = true;
            Game.DisplayNotification("~r~ALARM! ~w~Compound security alerted!");
            PlayRadioChatter("Ghost Lead", "We're compromised! All units, weapons free!");
            
            // Spawn reinforcements
            SpawnReinforcements();
        }

        private void SpawnReinforcements()
        {
            GameFiber.StartNew(() =>
            {
                for (int i = 0; i < 3; i++)
                {
                    var reinforcementVehicle = new Vehicle("GRANGER2", cartelBaseLocation.Around(100f));
                    reinforcementVehicle.IsPersistent = true;
                    
                    for (int j = 0; j < 4; j++)
                    {
                        var reinforcement = reinforcementVehicle.CreateRandomPedOnSeat(j);
                        reinforcement.IsPersistent = true;
                        reinforcement.BlockPermanentEvents = true;
                        reinforcement.RelationshipGroup = "HATES_PLAYER";
                        reinforcement.Inventory.GiveNewWeapon("WEAPON_ASSAULTRIFLE", 200, true);
                        reinforcement.Tasks.FightAgainst(Game.LocalPlayer.Character);
                        baseGuards.Add(reinforcement);
                    }
                    
                    reinforcementVehicles.Add(reinforcementVehicle);
                    GameFiber.Sleep(5000);
                }
            });
        }

        private void CallExtraction()
        {
            Game.DisplayNotification("~g~EXTRACTION CALLED! ~w~Move to extraction point for pickup.");
            PlayRadioChatter("Ghost Lead", "Annihilator 2 inbound for extraction. Mark the LZ!");
            
            // Create extraction blip
            extractionBlip = new Blip(extractionPoint);
            extractionBlip.Color = Color.Green;
            extractionBlip.Name = "Extraction Point";
            extractionBlip.Sprite = BlipSprite.Helicopter;
            extractionBlip.EnableRoute(Color.Green);
            
            // Bring helicopter for extraction
            GameFiber.StartNew(() =>
            {
                if (annihilator2.Exists())
                {
                    annihilator2.Driver.Tasks.DriveToPosition(extractionPoint + Vector3.WorldUp * 20f, 30f, VehicleDrivingFlags.Emergency);
                }
            });
        }

        private void CompleteMission()
        {
            // Calculate mission score
            string missionResult = CalculateMissionResult();
            
            Game.DisplayNotification("web_lossantospolicedept", "web_lossantospolicedept",
                "~g~MISSION COMPLETE", "~w~CONVOY BREAKER",
                missionResult);
                
            PlayRadioChatter("Handler", "Outstanding work, Shadow Unit. This mission never happened.");
            
            // Cinematic extraction
            StartExtractionCinematic();
            
            GameFiber.StartNew(() =>
            {
                GameFiber.Sleep(10000);
                End();
            });
        }

        private string CalculateMissionResult()
        {
            if (leaderCaptured && stealthMode)
                return "~g~GHOST SUCCESS: ~w~Silent operation, leader captured, intel secured.";
            else if (leaderCaptured)
                return "~y~PANTHER SUCCESS: ~w~Leader captured, partial stealth maintained.";
            else if (!stealthMode && enemiesNeutralized > 10)
                return "~o~ASSAULT SUCCESS: ~w~Loud operation, heavy resistance neutralized.";
            else
                return "~b~MISSION SUCCESS: ~w~Objectives completed, convoy interdicted.";
        }

        #endregion

        #region Tactical Controls and AI

        private void HandleTacticalControls()
        {
            // Coordinate with Ghost team (E key)
            if (Game.IsKeyDown(Keys.E) && DateTime.Now.Subtract(lastRadioChatter).TotalSeconds > 3)
            {
                CoordinateWithGhostTeam();
                lastRadioChatter = DateTime.Now;
            }
            
            // Tactical options (Q key)
            if (Game.IsKeyDown(Keys.Q))
            {
                ShowTacticalOptions();
            }
        }

        private void CoordinateWithGhostTeam()
        {
            if (!ghostTeamDeployed) return;
            
            string[] commands = new string[]
            {
                "Hold position and await signal.",
                "Move to overwatch positions.",
                "Engage targets on my mark.",
                "Switch to suppressed weapons.",
                "Prepare for extraction."
            };
            
            var randomCommand = commands[MathHelper.GetRandomInteger(commands.Length)];
            PlayRadioChatter("Shadow Unit", randomCommand);
            
            // Ghost team responds
            GameFiber.StartNew(() =>
            {
                GameFiber.Sleep(2000);
                PlayRadioChatter("Ghost Lead", "Copy that, Shadow Unit. Standing by.");
            });
        }

        private void ShowTacticalOptions()
        {
            if (currentPhase == MissionPhase.BaseInfiltration)
            {
                Game.DisplayHelp("~b~INFILTRATION OPTIONS:~n~" +
                    "~w~1. Ghost Protocol: Destroy generator for blackout advantage~n~" +
                    "~w~2. Panther Protocol: Fast and silent takedowns~n~" +
                    "~w~3. Assault Protocol: Direct frontal assault", 5000);
            }
            else
            {
                Game.DisplayHelp("~b~TACTICAL OPTIONS:~n~" +
                    "~w~E: Coordinate with Ghost team~n~" +
                    "~w~Suppressed weapons recommended~n~" +
                    "~w~Avoid civilian casualties", 3000);
            }
        }

        private bool IsConvoyUnderAttack()
        {
            return cartelMembers.Any(c => c.Exists() && c.IsInCombat);
        }

        private bool IsPlayerDetected()
        {
            return baseGuards.Any(g => g.Exists() && g.IsInCombat);
        }

        private void EngageGhostTeam()
        {
            foreach (var operative in ghostOperatives)
            {
                if (operative.Exists())
                {
                    var nearestCartel = cartelMembers
                        .Where(c => c.Exists() && c.IsAlive)
                        .OrderBy(c => Vector3.Distance(operative.Position, c.Position))
                        .FirstOrDefault();
                        
                    if (nearestCartel != null)
                    {
                        operative.Tasks.FightAgainst(nearestCartel);
                    }
                }
            }
        }

        #endregion

        #region Audio and Cinematics

        private void PlayRadioChatter(string speaker, string message)
        {
            Game.DisplaySubtitle($"~b~[{speaker}]: ~w~{message}", 4000);
            
            // Play radio static sound effect
            GameFiber.StartNew(() =>
            {
                NativeFunction.Natives.PLAY_SOUND_FRONTEND(-1, "RADIO_STATIC", "HUD_FRONTEND_DEFAULT_SOUNDSET", false);
            });
        }

        private void StartExtractionCinematic()
        {
            GameFiber.StartNew(() =>
            {
                // Fade out
                NativeFunction.Natives.DO_SCREEN_FADE_OUT(2000);
                GameFiber.Sleep(2500);
                
                // Position player near helicopter
                if (annihilator2.Exists())
                {
                    Game.LocalPlayer.Character.Position = annihilator2.Position + Vector3.RelativeRight * 5f;
                }
                
                // Fade in
                NativeFunction.Natives.DO_SCREEN_FADE_IN(2000);
                GameFiber.Sleep(1000);
                
                Game.DisplaySubtitle("~italic~Mission footage classified. Operational details redacted.", 5000);
                
                GameFiber.Sleep(3000);
                
                // Helicopter takes off
                if (annihilator2.Exists() && heliPilot.Exists())
                {
                    var takeoffPoint = annihilator2.Position + Vector3.WorldUp * 100f + Vector3.RelativeFront * 200f;
                    annihilator2.Driver.Tasks.DriveToPosition(takeoffPoint, 50f, VehicleDrivingFlags.Emergency);
                }
            });
        }

        #endregion

        #region UI Updates

        private void UpdateMissionUI()
        {
            // Display mission status
            var missionTime = DateTime.Now.Subtract(missionStartTime);
            var statusText = $"~b~CONVOY BREAKER~n~" +
                           $"~w~Phase: {currentPhase}~n~" +
                           $"~w~Time: {missionTime:mm\\:ss}~n~" +
                           $"~w~Status: {(stealthMode ? "~g~STEALTH" : "~r~COMPROMISED")}";
                           
            NativeFunction.Natives.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING");
            NativeFunction.Natives.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(statusText);
            NativeFunction.Natives.END_TEXT_COMMAND_DISPLAY_TEXT(0.01f, 0.3f, 0);
        }

        #endregion

        #region Cleanup

        public override void End()
        {
            try
            {
                Game.LogTrivial("ConvoyBreakerCallout: Cleaning up mission resources...");
                
                // Clean up blips
                if (convoyBlip?.Exists() == true) convoyBlip.Delete();
                if (ambushBlip?.Exists() == true) ambushBlip.Delete();
                if (baseBlip?.Exists() == true) baseBlip.Delete();
                if (extractionBlip?.Exists() == true) extractionBlip.Delete();
                
                operativeBlips.Where(b => b?.Exists() == true).ToList().ForEach(b => b.Delete());
                
                // Clean up vehicles
                convoyVehicles.Where(v => v?.Exists() == true).ToList().ForEach(v => v.Delete());
                reinforcementVehicles.Where(v => v?.Exists() == true).ToList().ForEach(v => v.Delete());
                if (annihilator2?.Exists() == true) annihilator2.Delete();
                
                // Clean up NPCs
                cartelMembers.Where(p => p?.Exists() == true).ToList().ForEach(p => p.Delete());
                ghostOperatives.Where(p => p?.Exists() == true).ToList().ForEach(p => p.Delete());
                baseGuards.Where(p => p?.Exists() == true).ToList().ForEach(p => p.Delete());
                if (cartelLeader?.Exists() == true) cartelLeader.Delete();
                if (heliPilot?.Exists() == true) heliPilot.Delete();
                
                // Clean up objects
                baseLights.Where(o => o?.Exists() == true).ToList().ForEach(o => o.Delete());
                guardTowers.Where(o => o?.Exists() == true).ToList().ForEach(o => o.Delete());
                if (generator?.Exists() == true) generator.Delete();
                
                // Restore lighting
                NativeFunction.Natives.SET_ARTIFICIAL_LIGHTS_STATE(true);
                
                Game.DisplayNotification("~b~Operation Convoy Breaker concluded. ~w~All traces eliminated.");
                Game.LogTrivial("ConvoyBreakerCallout: Mission cleanup completed successfully.");
            }
            catch (Exception ex)
            {
                Game.LogTrivial($"ConvoyBreakerCallout: Error during cleanup - {ex.Message}");
            }
            
            base.End();
        }

        #endregion
    }
}
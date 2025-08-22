using System;
using LSPD_First_Response.Mod.API;
using Rage;

[assembly: Rage.Attributes.Plugin("ConvoyBreakerCallout", Description = "Operation: Convoy Breaker - Tactical cartel interdiction callout", Author = "TacticalOps")]

namespace ConvoyBreakerCallout
{
    public class Plugin
    {
        public static void Main()
        {
            try
            {
                Game.LogTrivial("ConvoyBreakerCallout: Starting plugin initialization...");
                
                // Subscribe to on-duty state changes
                Functions.OnOnDutyStateChanged += OnOnDutyStateChangedHandler;
                
                Game.LogTrivial("===========================================");
                Game.LogTrivial("  CONVOY BREAKER CALLOUT v1.0");
                Game.LogTrivial("  Operation: Convoy Breaker - Loaded");
                Game.LogTrivial("  Tactical cartel interdiction callout");
                Game.LogTrivial("===========================================");
                
                // If the player is already on duty, register immediately
                if (LspdfrCompat.IsPlayerOnDuty())
                {
                    Game.LogTrivial("ConvoyBreakerCallout: Player already on duty at load; registering callout now...");
                    Functions.RegisterCallout(typeof(ConvoyBreakerCallout));
                    Game.DisplayNotification("web_lossantospolicedept", "web_lossantospolicedept", 
                        "~w~CONVOY BREAKER", "~b~Tactical Callout Loaded", 
                        "~w~Black operations callout now available. Stay frosty, operator.");
                }
                
                // Run diagnostic tests
                DiagnosticHelper.LogDiagnosticInfo();
                DiagnosticHelper.TestBasicFunctionality();
                
                Game.LogTrivial("ConvoyBreakerCallout: Plugin initialization completed successfully.");
            }
            catch (Exception ex)
            {
                Game.LogTrivial($"ConvoyBreakerCallout: CRITICAL ERROR during initialization - {ex.Message}");
                Game.LogTrivial($"ConvoyBreakerCallout: Stack trace - {ex.StackTrace}");
            }
        }

        public static void Finally()
        {
            try
            {
                Functions.OnOnDutyStateChanged -= OnOnDutyStateChangedHandler;
                Game.LogTrivial("ConvoyBreakerCallout: Plugin cleanup completed.");
            }
            catch (Exception ex)
            {
                Game.LogTrivial($"ConvoyBreakerCallout: Error during plugin cleanup - {ex.Message}");
            }
        }

        private static void OnOnDutyStateChangedHandler(bool onDuty)
        {
            try
            {
                if (onDuty)
                {
                    Game.LogTrivial("ConvoyBreakerCallout: Player went on duty, registering callout...");
                    
                    // Register the callout when going on duty
                    Functions.RegisterCallout(typeof(ConvoyBreakerCallout));
                    
                    Game.DisplayNotification("web_lossantospolicedept", "web_lossantospolicedept", 
                        "~w~CONVOY BREAKER", "~b~Tactical Callout Loaded", 
                        "~w~Black operations callout now available. Stay frosty, operator.");
                    
                    Game.LogTrivial("ConvoyBreakerCallout: Callout registered successfully.");
                }
                else
                {
                    Game.LogTrivial("ConvoyBreakerCallout: Player went off duty.");
                }
            }
            catch (Exception ex)
            {
                Game.LogTrivial($"ConvoyBreakerCallout: ERROR in OnOnDutyStateChanged - {ex.Message}");
                Game.LogTrivial($"ConvoyBreakerCallout: Stack trace - {ex.StackTrace}");
            }
        }
    }
}
using System;
using LSPD_First_Response.Mod.API;
using Rage;

[assembly: Rage.Attributes.Plugin("ConvoyBreakerCallout", Description = "Operation: Convoy Breaker - Tactical cartel interdiction callout", Author = "TacticalOps")]

namespace ConvoyBreakerCallout
{
    public class Plugin
    {
        public static void Initialize()
        {
            // Subscribe to on-duty state changes
            Functions.OnOnDutyStateChanged += OnOnDutyStateChangedHandler;
            
            Game.LogTrivial("===========================================");
            Game.LogTrivial("  CONVOY BREAKER CALLOUT v1.0");
            Game.LogTrivial("  Operation: Convoy Breaker - Loaded");
            Game.LogTrivial("  Tactical cartel interdiction callout");
            Game.LogTrivial("===========================================");
        }

        public static void Finally()
        {
            Game.LogTrivial("ConvoyBreakerCallout: Plugin cleanup completed.");
        }

        private static void OnOnDutyStateChangedHandler(bool onDuty)
        {
            if (onDuty)
            {
                // Register the callout when going on duty
                Functions.RegisterCallout(typeof(ConvoyBreakerCallout));
                
                Game.DisplayNotification("web_lossantospolicedept", "web_lossantospolicedept", 
                    "~w~CONVOY BREAKER", "~b~Tactical Callout Loaded", 
                    "~w~Black operations callout now available. Stay frosty, operator.");
                
                Game.LogTrivial("ConvoyBreakerCallout: Callout registered successfully.");
            }
        }
    }
}
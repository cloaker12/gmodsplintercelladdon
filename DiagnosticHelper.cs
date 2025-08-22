using System;
using System.IO;
using LSPD_First_Response.Mod.API;
using Rage;

namespace ConvoyBreakerCallout
{
    /// <summary>
    /// Diagnostic helper to troubleshoot plugin loading issues
    /// </summary>
    public static class DiagnosticHelper
    {
        private static string logPath = "plugins/LSPDFR/ConvoyBreaker_Diagnostic.log";
        
        public static void LogDiagnosticInfo()
        {
            try
            {
                using (StreamWriter writer = new StreamWriter(logPath, true))
                {
                    writer.WriteLine($"=== CONVOY BREAKER DIAGNOSTIC LOG - {DateTime.Now} ===");
                    writer.WriteLine($"Game Version: {Game.ProductVersion}");
                    writer.WriteLine($"LSPDFR Version: {Functions.GetVersion()}");
                    writer.WriteLine($"Plugin Assembly Location: {typeof(Plugin).Assembly.Location}");
                    writer.WriteLine($"Is LSPDFR Running: {Functions.IsLSPDFRRunning()}");
                    writer.WriteLine($"Player Character Exists: {Game.LocalPlayer?.Character?.Exists()}");
                    writer.WriteLine($"Current Position: {Game.LocalPlayer?.Character?.Position}");
                    writer.WriteLine("=== END DIAGNOSTIC INFO ===");
                    writer.WriteLine();
                }
                
                Game.LogTrivial("ConvoyBreakerCallout: Diagnostic information written to " + logPath);
            }
            catch (Exception ex)
            {
                Game.LogTrivial($"ConvoyBreakerCallout: Failed to write diagnostic log - {ex.Message}");
            }
        }
        
        public static void TestBasicFunctionality()
        {
            try
            {
                Game.LogTrivial("=== CONVOY BREAKER FUNCTIONALITY TEST ===");
                
                // Test 1: Basic LSPDFR functions
                Game.LogTrivial($"Test 1 - LSPDFR Running: {Functions.IsLSPDFRRunning()}");
                
                // Test 2: Player character
                var playerExists = Game.LocalPlayer?.Character?.Exists() ?? false;
                Game.LogTrivial($"Test 2 - Player Exists: {playerExists}");
                
                // Test 3: World position queries
                if (playerExists)
                {
                    var playerPos = Game.LocalPlayer.Character.Position;
                    var nearbyPos = World.GetNextPositionOnStreet(playerPos.Around(100f));
                    Game.LogTrivial($"Test 3 - Position Query: Player at {playerPos}, Nearby street at {nearbyPos}");
                }
                
                // Test 4: Vehicle spawning test (cleanup immediately)
                try
                {
                    var testVehicle = new Vehicle("POLICE", Game.LocalPlayer.Character.Position + Vector3.RelativeFront * 10f);
                    if (testVehicle.Exists())
                    {
                        Game.LogTrivial("Test 4 - Vehicle Spawn: SUCCESS");
                        testVehicle.Delete();
                    }
                    else
                    {
                        Game.LogTrivial("Test 4 - Vehicle Spawn: FAILED - Vehicle doesn't exist");
                    }
                }
                catch (Exception ex)
                {
                    Game.LogTrivial($"Test 4 - Vehicle Spawn: FAILED - {ex.Message}");
                }
                
                Game.LogTrivial("=== FUNCTIONALITY TEST COMPLETE ===");
            }
            catch (Exception ex)
            {
                Game.LogTrivial($"ConvoyBreakerCallout: Error during functionality test - {ex.Message}");
            }
        }
    }
}
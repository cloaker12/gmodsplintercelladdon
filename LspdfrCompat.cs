using System;
using System.Reflection;
using LSPD_First_Response.Mod.API;
using Rage;

namespace ConvoyBreakerCallout
{
    internal static class LspdfrCompat
    {
        private static bool? cachedIsOnDuty;

        public static bool IsPlayerOnDuty()
        {
            try
            {
                if (cachedIsOnDuty.HasValue)
                {
                    return cachedIsOnDuty.Value;
                }

                Type functionsType = typeof(Functions);

                // Try method: IsPlayerOnDuty()
                MethodInfo method = functionsType.GetMethod("IsPlayerOnDuty", BindingFlags.Public | BindingFlags.Static);
                if (method != null && method.ReturnType == typeof(bool) && method.GetParameters().Length == 0)
                {
                    bool value = (bool)method.Invoke(null, null);
                    cachedIsOnDuty = value;
                    return value;
                }

                // Try property: IsPlayerOnDuty
                PropertyInfo prop = functionsType.GetProperty("IsPlayerOnDuty", BindingFlags.Public | BindingFlags.Static);
                if (prop != null && prop.PropertyType == typeof(bool))
                {
                    bool value = (bool)prop.GetValue(null);
                    cachedIsOnDuty = value;
                    return value;
                }

                // Try alternate method/property names
                MethodInfo altMethod = functionsType.GetMethod("PlayerIsOnDuty", BindingFlags.Public | BindingFlags.Static);
                if (altMethod != null && altMethod.ReturnType == typeof(bool) && altMethod.GetParameters().Length == 0)
                {
                    bool value = (bool)altMethod.Invoke(null, null);
                    cachedIsOnDuty = value;
                    return value;
                }

                PropertyInfo altProp = functionsType.GetProperty("PlayerIsOnDuty", BindingFlags.Public | BindingFlags.Static);
                if (altProp != null && altProp.PropertyType == typeof(bool))
                {
                    bool value = (bool)altProp.GetValue(null);
                    cachedIsOnDuty = value;
                    return value;
                }

                // Try generic IsOnDuty
                MethodInfo genericMethod = functionsType.GetMethod("IsOnDuty", BindingFlags.Public | BindingFlags.Static);
                if (genericMethod != null && genericMethod.ReturnType == typeof(bool) && genericMethod.GetParameters().Length == 0)
                {
                    bool value = (bool)genericMethod.Invoke(null, null);
                    cachedIsOnDuty = value;
                    return value;
                }

                PropertyInfo genericProp = functionsType.GetProperty("IsOnDuty", BindingFlags.Public | BindingFlags.Static);
                if (genericProp != null && genericProp.PropertyType == typeof(bool))
                {
                    bool value = (bool)genericProp.GetValue(null);
                    cachedIsOnDuty = value;
                    return value;
                }

                return false;
            }
            catch (Exception ex)
            {
                Game.LogTrivial($"ConvoyBreakerCallout: LspdfrCompat.IsPlayerOnDuty failed - {ex.Message}");
                return false;
            }
        }
    }
}
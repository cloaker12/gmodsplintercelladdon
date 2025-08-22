using System;
using System.Linq;
using System.Reflection;
using Rage;

namespace ConvoyBreakerCallout
{
	internal static class TasksCompatExtensions
	{
		/// <summary>
		/// Compatibility shim: allow using 3-argument FollowToOffsetFromEntity across different RPH versions.
		/// Resolves to the available overload and supplies sensible default values for missing parameters.
		/// </summary>
		public static void FollowToOffsetFromEntity(this Tasks tasks, Entity targetEntity, Vector3 offset, float movementSpeed)
		{
			if (tasks == null) throw new ArgumentNullException(nameof(tasks));
			if (targetEntity == null) throw new ArgumentNullException(nameof(targetEntity));

			try
			{
				// Find instance methods named FollowToOffsetFromEntity
				var candidateMethods = typeof(Tasks)
					.GetMethods(BindingFlags.Public | BindingFlags.Instance)
					.Where(m => m.Name == nameof(FollowToOffsetFromEntity))
					.ToArray();

				if (candidateMethods.Length == 0)
				{
					Game.LogTrivial("ConvoyBreakerCallout: FollowToOffsetFromEntity method not found on Rage.Tasks. Skipping.");
					return;
				}

				// Prefer the overload with the most parameters so we can pass all defaults
				var targetMethod = candidateMethods
					.OrderByDescending(m => m.GetParameters().Length)
					.First();

				var parameters = targetMethod.GetParameters();
				object[] args = new object[parameters.Length];

				// Map the common signature order: (Entity, Vector3, float, int, float, bool)
				if (parameters.Length >= 1) args[0] = targetEntity;
				if (parameters.Length >= 2) args[1] = offset;
				if (parameters.Length >= 3) args[2] = movementSpeed;
				if (parameters.Length >= 4) args[3] = -1;            // time (ms), -1 = infinite
				if (parameters.Length >= 5) args[4] = 5f;            // stopping range (meters)
				if (parameters.Length >= 6) args[5] = true;          // persist following

				targetMethod.Invoke(tasks, args);
			}
			catch (TargetInvocationException tie)
			{
				Game.LogTrivial($"ConvoyBreakerCallout: Error invoking FollowToOffsetFromEntity - {tie.InnerException?.Message ?? tie.Message}");
			}
			catch (Exception ex)
			{
				Game.LogTrivial($"ConvoyBreakerCallout: Failed to execute FollowToOffsetFromEntity compat call - {ex.Message}");
			}
		}
	}
}
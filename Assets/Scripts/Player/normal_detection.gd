extends RayCast3D

@export var player: RigidBody3D

# This should be done only when touching the ground

func _physics_process(delta: float) -> void:
	if $"../../StateMachine".is_touching_ground():
		if is_colliding():
			var normal = get_collision_normal()
			$"../../StateMachine".floor_normals = normal
			# Player's facing direction
			var forward = -player.global_transform.basis.z

			# Re-project forward onto the ramp plane (orthogonal to normal)
			forward = (forward - forward.project(normal)).normalized()

			# Build orthonormal basis
			var right = forward.cross(normal).normalized()
			var up = normal.normalized()

			# Godot uses columns: Basis(x, y, z)
			var target_basis = Basis(right, up, -forward)

			# Smooth rotation only
			var current = player.global_transform
			current.basis = target_basis
			player.global_transform = current
	else:
		# Player's facing direction (keep yaw)
		var forward = -player.global_transform.basis.z
		forward.y = 0.0               # flatten to XZ plane so yaw is preserved
		forward = forward.normalized()

		# World up
		var up = Vector3.UP

		# Rebuild right from cross product
		var right = forward.cross(up).normalized()

		# Recalculate forward in case it's slightly skewed
		forward = up.cross(right).normalized()

		# Construct target basis with preserved yaw
		var target_basis = Basis(right, up, -forward)

		# Smooth rotation towards target (only roll/pitch corrected)
		var current = player.global_transform
		current.basis = current.basis.slerp(target_basis, delta * 5.0)
		player.global_transform = current

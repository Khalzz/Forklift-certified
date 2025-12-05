extends Node3D

func _physics_process(delta: float) -> void:
	var rb = $"../../StateMachine".rigid_body
	var velocity = rb.linear_velocity
	
	# Check angle between velocity and Y-axis (up vector)
	var angle_to_y = velocity.normalized().angle_to(Vector3.UP)
	
	# Check if drifting (angle between forward direction and velocity)
	var angle_to_forward = rb.transform.basis.z.angle_to(velocity.normalized())
	
	if angle_to_forward > 0.5 and $"../../StateMachine".is_touching_ground() and velocity.length() > 1.0:
		$TyreMarkGeneratorRr.spawnMark(true)
		$TyreMarkGeneratorRl.spawnMark(true)
	else:
		$TyreMarkGeneratorRr.spawnMark(false)
		$TyreMarkGeneratorRl.spawnMark(false)

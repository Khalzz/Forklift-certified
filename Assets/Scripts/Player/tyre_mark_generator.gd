extends Node3D

var tyreMark = preload("res://Assets/Prefabs/Player/tyreMark.tscn")
@export var rigidbody: RigidBody3D = null 

# Add rate limiting
var spawn_timer = 0.0
var spawn_interval = 0.05  # Spawn every 0.05 seconds (20 marks per second)

func spawnMark(should_show):
	if should_show:
		# Only spawn if enough time has passed
		spawn_timer += get_physics_process_delta_time()
		
		if spawn_timer < spawn_interval:
			return
		
		spawn_timer = 0.0  # Reset timer
		
		var mark_instance = tyreMark.instantiate()
		var spawn_pos = global_position
		
		get_tree().current_scene.add_child(mark_instance)
		mark_instance.global_position = spawn_pos
		
		if rigidbody and rigidbody.linear_velocity.length() > 0.1:
			var velocity_dir = rigidbody.linear_velocity.normalized()
			mark_instance.look_at(spawn_pos + velocity_dir, Vector3.UP)
	else:
		# Reset timer when not drifting
		spawn_timer = 0.0

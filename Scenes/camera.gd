extends Camera3D

@export var followable: Node3D

enum CameraStates {
	GameCamera, # Follows a object 
	SpotCamera, # Looks at an object
}

var state = CameraStates.GameCamera

var xr_input: float = 0.0
var yr_input: float = 0.0

# Camera orbit parameters
var distance := 1.0
var horizontal_angle := 0.0
var vertical_angle := 0.3

var sensitivity := 3.0
var min_pitch := 0.1
var max_pitch := 1.5

# Rotation follow parameters
var follow_movement := true
var movement_threshold := 0.1  # Minimum speed to consider movement

# Smoothing
var smoothed_position := Vector3.ZERO
var smoothed_target := Vector3.ZERO
var position_lerp_speed := 8.0
var target_lerp_speed := 10.0

var last_direction := Vector3.FORWARD  # store last valid horizontal direction
var last_position := Vector3.ZERO  # store last valid horizontal direction

func _process(delta: float) -> void:
	if not followable is RigidBody3D:
		game_camera(delta, follow_node_movement(), 2.0)

func _physics_process(delta: float) -> void:
	if followable == null:
		return
	
	if followable is RigidBody3D:
		game_camera(delta, follow_rigidbody_velocity(), 1.0)

func apply_deadzone(value: float, deadzone: float) -> float:
	if abs(value) < deadzone:  
		return 0.0
	else:
		return value

func follow_node_movement() -> Vector3:
	if followable == null:
		return global_position

	# Calculate horizontal movement
	var movement: Vector3 = followable.global_position - last_position
	last_position = followable.global_position

	movement.y = 0.0

	# Always update direction if movement exists, else keep previous
	if movement.length() > 0.001:
		last_direction = movement.normalized()

	# Apply camera offset
	var offset_up   = Vector3(0.0, 0.2, 0.0)
	var offset_back = -last_direction

	return followable.global_position + offset_up + offset_back
	
func follow_rigidbody_velocity() -> Vector3:
	if followable is RigidBody3D:
		var velocity: Vector3 = followable.linear_velocity
		velocity.y = 0.0
		
		if velocity.length() > movement_threshold:
			last_direction = velocity.normalized()

		var offset_up    = Vector3.UP * 0.8
		var offset_back  = -last_direction * 1.0
		return followable.global_position + offset_up + offset_back
	
	var offset_up    = Vector3.UP * 1.0
	var offset_back  = -last_direction * 2.0
	return followable.global_position + offset_up + offset_back

func game_camera(delta: float, camera_position: Vector3, multiplier) -> void:
	smoothed_position = smoothed_position.lerp(camera_position, delta * position_lerp_speed * multiplier)
	smoothed_target   = smoothed_target.lerp(followable.global_position, delta * target_lerp_speed * multiplier)

	global_position = smoothed_position
	look_at(smoothed_target, Vector3.UP)

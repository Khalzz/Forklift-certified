extends Node3D

@export var player_model: Node3D
@export var sparks: Node3D
@export var rigidbody: RigidBody3D
@export var wheel_parent: Node3D  # Array of wheel parent nodes to counter-rotate

# Tilt settings
@export_group("Tilt Settings")
@export var pitch_strength: float = 0.5
@export var roll_strength: float = 0.8
@export var tilt_smoothing: float = 6.0
@export var max_pitch: float = 30.0  # degrees
@export var max_roll: float = 45.0   # degrees
@export var enable_tilt: bool = true

# Internal state
var last_velocity: Vector3 = Vector3.ZERO
var current_tilt: Vector3 = Vector3.ZERO

func _ready():
	if rigidbody:
		last_velocity = rigidbody.linear_velocity
	else:
		push_warning("No RigidBody3D assigned to player model tilt script!")

func _physics_process(delta: float) -> void:
	if enable_tilt and rigidbody and player_model and delta > 0:
		update_tilt(delta)

func update_tilt(delta: float) -> void:
	var velocity = rigidbody.linear_velocity
	
	# Calculate acceleration (change in velocity)
	var acceleration = (velocity - last_velocity) / delta
	
	# Transform acceleration to vehicle's local space
	var local_accel = rigidbody.global_transform.basis.inverse() * acceleration
	
	# Convert to G-forces (divide by gravity)
	var g_force = local_accel / 9.8
	
	# Calculate target tilt angles in radians
	var target_pitch = -g_force.z * pitch_strength
	var target_roll = g_force.x * roll_strength
	
	# Clamp to max angles
	target_pitch = clamp(target_pitch, deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
	target_roll = clamp(target_roll, deg_to_rad(-max_roll), deg_to_rad(max_roll))
	
	var target_tilt = Vector3(target_pitch, 0, target_roll)
	
	# Smooth interpolation
	current_tilt = current_tilt.lerp(target_tilt, delta * tilt_smoothing)
	
	# Apply tilt to player model (preserve Y rotation)
	var current_y_rotation = player_model.rotation.y
	player_model.rotation = Vector3(current_tilt.x, current_y_rotation, current_tilt.z)
	
	# Counter-rotate wheel parents to keep them level
	# var parent_y_rotation = wheel_parent.rotation.y
	# wheel_parent.rotation = Vector3(-current_tilt.x, parent_y_rotation, -current_tilt.z)
	
	last_velocity = velocity

func stretch(delta, multiplier):
	if player_model:
		player_model.scale = player_model.scale.lerp(Vector3(0.05, 0.15, 0.05), delta * multiplier)
	
func squash(delta, multiplier):
	if player_model:
		player_model.scale = player_model.scale.lerp(Vector3(0.15, 0.05, 0.15), delta * multiplier)
	
func base(delta, multiplier):
	if player_model:
		player_model.scale = player_model.scale.lerp(Vector3(0.1, 0.1, 0.1), delta * 5)

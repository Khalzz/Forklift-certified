extends Node3D

enum CameraType {
	FollowDirection,
	Fixed
}

enum Cameras {
	FarBack,
	CloseBack,
	Grind
}

@export var followable: Node3D

@export var far_back_camera: Camera3D
@export var close_back_camera: Camera3D
@export var grind_camera: Camera3D

@onready var camera_data = {
	Cameras.FarBack: {
		"camera": far_back_camera,
		"type":  CameraType.FollowDirection,
		"smoothing": 10
	},
	Cameras.CloseBack: {
		"camera": close_back_camera,
		"type":  CameraType.FollowDirection,
		"smoothing": 10
	},
	Cameras.Grind: {
		"camera": grind_camera,
		"type":  CameraType.FollowDirection,
		"smoothing": 10
	}
}

@export var camera_selected = Cameras.FarBack

var movement_threshold := 0.1  # Minimum speed to consider movement
var last_direction := Vector3.FORWARD  # store last valid horizontal direction
var last_position := Vector3.ZERO  # store last valid horizontal direction

func set_camera(camera: Cameras):
	camera_selected = camera

func set_followable(element):
	followable = element
	last_position = followable.global_position
	last_direction = Vector3.FORWARD

func _ready() -> void:
	for camera in camera_data.values():
		camera["relative_offset"] = followable.to_local(camera["camera"].global_position)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_camera"):
		camera_selected += 1
		if camera_selected > Cameras.CloseBack:
			camera_selected = Cameras.FarBack
	
	if not followable is RigidBody3D:
		cameras_definition(false, delta)

func _physics_process(delta: float) -> void:
	if followable is RigidBody3D:
		cameras_definition(true, delta)

func cameras_definition(physics: bool, delta):
	match camera_data[camera_selected]["type"]:
		CameraType.FollowDirection:
			game_camera(delta, follow_direction(physics))
		CameraType.Fixed:
			game_camera(delta, fixed_follow())

func fixed_follow() -> Vector3:
	var rel_offset: Vector3 = camera_data[camera_selected]["relative_offset"]

	# Rotate the relative offset by the followable's rotation (basis) using * operator
	var rotated_offset = followable.global_transform.basis * rel_offset

	# Position is the followable's position plus the rotated offset
	return followable.global_position + rotated_offset
	
func follow_direction(use_rigidbody: bool) -> Vector3:
	var rel_offset: Vector3 = camera_data[camera_selected]["relative_offset"]

	if use_rigidbody and followable is RigidBody3D:
		var velocity: Vector3 = followable.linear_velocity
		velocity.y = 0.0

		if velocity.length() > movement_threshold:
			last_direction = velocity.normalized()

		# Apply offset based on last_direction direction
		var offset = Vector3(
			rel_offset.z * last_direction.x,
			rel_offset.y,
			rel_offset.z * last_direction.z
		)

		return followable.global_position + offset
	else:
		var movement: Vector3 = followable.global_position - last_position
		last_position = followable.global_position
		movement.y = 0.0

		if movement.length() > 0.001:
			last_direction = movement.normalized()

		# Apply offset based on last_direction direction
		var offset = Vector3(
			rel_offset.z * last_direction.x,
			rel_offset.y,
			rel_offset.z * last_direction.z
		)

		return followable.global_position + offset

func game_camera(delta: float, camera_position: Vector3) -> void:
	var cam = camera_data[camera_selected]["camera"]
	cam.current = true
	
	cam.look_at(followable.global_position)
	
	# Smoothing factor (0.1 to 0.3 is usually good; higher values = more smoothing)
	var smoothing_speed = 10.0  
	
	if camera_data[camera_selected].has("smoothing"):
		cam.global_position = cam.global_position.lerp(camera_position, camera_data[camera_selected]["smoothing"] * delta)
	else:
		cam.global_position = camera_position

		

		

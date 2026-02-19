extends Node3D

enum CameraType {
	FollowDirection,
	Fixed
}

enum Cameras {
	CloseBack,
	FarBack,
	Grind
}

@export var followable: Node3D
@export var cameras_setter: Node3D

@onready var camera_data = {
	Cameras.CloseBack: {
		"camera": $Cameras/BackCloseCamera,
		"type":  CameraType.FollowDirection,
		"smoothing": 30
	},
	Cameras.FarBack: {
		"camera": $Cameras/BackFarCamera,
		"type":  CameraType.FollowDirection,
		"smoothing": 30
	},
	Cameras.Grind: {
		"camera": $Cameras/GrindCamera,
		"type":  CameraType.FollowDirection,
		"smoothing": 30
	}
}

@export var camera_selected = Cameras.CloseBack
var movement_threshold := 0.1
var last_direction := Vector3.FORWARD
var last_position := Vector3.ZERO

func set_camera(camera: Cameras):
	camera_selected = camera

func set_followable(element):
	followable = element
	last_position = followable.global_position
	last_direction = -followable.global_transform.basis.z  # Use initial facing direction

func _ready():
	if followable:
		last_position = followable.global_position
		last_direction = -followable.global_transform.basis.z

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_camera"):
		camera_selected += 1
		
		if not camera_data.has(camera_selected):
			camera_selected = 0
			
	if not followable is RigidBody3D:
		cameras_definition(false, delta)

func _physics_process(delta: float) -> void:
	if followable is RigidBody3D:
		cameras_definition(true, delta)

func cameras_definition(physics: bool, delta):
	match camera_data[camera_selected]["type"]:
		CameraType.FollowDirection:
			follow_direction(physics, delta)
		CameraType.Fixed:
			fixed_follow()
			
	$ActualCamera.global_position = $ActualCamera.global_position.lerp(
		camera_data[camera_selected]["camera"].global_position, 
		delta * camera_data[camera_selected]["smoothing"]
	)
	$ActualCamera.look_at(followable.global_position)
	$ActualCamera.fov = camera_data[camera_selected]["camera"].fov

func fixed_follow() -> void:
	cameras_setter.global_position = followable.global_position
	cameras_setter.global_transform.basis = followable.global_transform.basis

# IT SHOULD FOLLOW THE AVERAGE MOVEMENT WHERE THE OBJECT IS MOVING WITH A SMALL LERP, SO WHEN I MAKE THE OBKECT DO ZIG ZAGS THE CAMERA DOES NOT JUMPS INSTANTLY AND WEIRDLY
func follow_direction(use_rigidbody: bool, delta: float) -> void:
	var current_position = followable.global_position
	var target_direction := last_direction  # default to current if no movement

	if use_rigidbody and followable is RigidBody3D:
		var velocity: Vector3 = followable.linear_velocity
		velocity.y = 0.0
		if velocity.length() > movement_threshold:
			target_direction = velocity.normalized()
	else:
		var movement: Vector3 = current_position - last_position
		movement.y = 0.0
		var speed = movement.length() / delta if delta > 0 else 0
		if speed > movement_threshold:
			target_direction = movement.normalized()

	last_position = current_position

	# Smoothly rotate toward the target direction instead of snapping
	last_direction = last_direction.slerp(target_direction, delta * 5.0).normalized()

	var basis = Basis()
	basis.z = last_direction
	basis.x = basis.z.cross(Vector3.UP).normalized()
	basis.y = basis.x.cross(basis.z).normalized()

	cameras_setter.global_transform.basis = basis
	cameras_setter.global_position = current_position

extends Node3D

@export var target: Node3D
@export var distance := 5.0
@export var min_distance := 2.0
@export var max_distance := 10.0
@export var mouse_sensitivity := 0.003
@export var zoom_speed := 0.5
@export var min_pitch := -80.0
@export var max_pitch := 80.0

var camera: Camera3D
var yaw := 0.0
var pitch := -20.0  # Start with a slight downward angle

func _ready() -> void:
	camera = Camera3D.new()
	add_child(camera)
	camera.current = true  # Make this the active camera
	
	# Initialize pitch in radians
	pitch = deg_to_rad(-20.0)
	
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clamp(distance - zoom_speed, min_distance, max_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clamp(distance + zoom_speed, min_distance, max_distance)
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if not target:
		return
	
	global_position = target.global_position
	rotation.y = yaw
	rotation.x = pitch
	camera.position = Vector3(0, 0, distance)

extends Node3D

enum Selectables {
	Play,
	Settings,
	Exit
}

@onready var cameras = {
	Selectables.Play: {
		"camera": $Play/Camera,
	},
	Selectables.Settings: {
		"camera": $Settings/Camera
	},
	Selectables.Exit: {
		"camera": $Exit/Camera
	}
}

var selected = Selectables.Play

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if not cameras.has(selected):
		selected = 0
	
	$ActiveCamera.global_position = lerp($ActiveCamera.global_position, cameras[selected].camera.global_position, delta * 10.0)
	$ActiveCamera.global_rotation = lerp($ActiveCamera.global_rotation, cameras[selected].camera.global_rotation, delta * 10.0)
	$ActiveCamera.fov = lerp($ActiveCamera.fov, cameras[selected].camera.fov, delta)
	
	if Input.is_action_just_pressed("ui_left"):
		selected -= 1
	if Input.is_action_just_pressed("ui_right"):
		selected += 1

	if Input.is_action_just_pressed("ui_select"):
		match selected:
			Selectables.Play:
				get_tree().change_scene_to_file("res://Scenes/Test.tscn")
			Selectables.Exit:
				get_tree().quit()

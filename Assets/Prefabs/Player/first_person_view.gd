extends Node3D

@export var steering_wheel: Sprite2D
@export var cockpit_ui: Control

func _process(delta: float) -> void:
	# When pressing first person we activate the camera inside here
	# also we will show a ui in particular
	var new_rotation = 1 * Controller.l_stick.x
	steering_wheel.rotation = lerp(steering_wheel.rotation, new_rotation, delta * 10.0)
	
	if Input.is_action_pressed("first_person"):
		activate()
	else:
		disactivate()

func activate():
	$FPCamera.current = true
	$"../Models".visible = false
	cockpit_ui.visible = true
	
func disactivate():
	$FPCamera.current = false
	$"../Models".visible = true
	cockpit_ui.visible = false

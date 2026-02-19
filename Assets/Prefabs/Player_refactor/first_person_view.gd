extends Node3D

func _process(delta: float) -> void:
	# When pressing first person we activate the camera inside here
	# also we will show a ui in particular
	var new_rotation = 1 * Controller.l_stick.x
	$CockpitView/TextureRect.rotation = lerp($CockpitView/TextureRect.rotation, new_rotation, delta * 10.0)
	
	if Input.is_action_pressed("first_person"):
		activate()
	else:
		disactivate()

func activate():
	$FPCamera.current = true
	$"../Models".visible = false
	$CockpitView.visible = true
	
func disactivate():
	$FPCamera.current = false
	$"../Models".visible = true
	$CockpitView.visible = false
	

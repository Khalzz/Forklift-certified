extends State

@export var models: Node3D

func update(delta: float):
	if get_parent().is_touching_ground():
		if Input.is_action_pressed("jump"): 
			models.squash(delta, 50)
		if Input.is_action_just_released("jump"):
			get_parent().change_state(get_parent().States.Jumping)
		
	if Input.is_action_pressed("l_trigger") or Input.is_action_pressed("r_trigger"):
		get_parent().change_state(get_parent().States.Running)
		
	models.base(delta, 10)
	
func fixed_update(delta: float):
	pass

extends State

func update(delta: float):
	if get_parent().is_touching_ground():
		$"../..".squash(delta, 200)
		get_parent().state = get_parent().States.Idle
	
func fixed_update(delta: float):
	pass

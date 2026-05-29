extends VBoxContainer

const TRICK_SCENE = preload("res://Assets/Prefabs/Player/UI/Trick/trick.tscn")

# grind_id -> trick instance, so we can update it later
var active_grinds := {}

func add_trick(trick_name: String, trick_points: float) -> void:
	print("YAPO MIERDA")
	var instance = TRICK_SCENE.instantiate()
	add_child(instance)
	move_child(instance, 0)
	instance.text = "%s  %d pts" % [trick_name, trick_points]
	print("added trick, instance: ", instance, " text: ", instance.text, " visible: ", instance.visible)
	print("TricksList visible: ", visible, " position: ", global_position)
	
func add_grind(grind_id: int, trick_name: String, trick_points: float) -> void:
	var instance = TRICK_SCENE.instantiate()
	add_child(instance)
	move_child(instance, 0)
	instance.text = "%s  %d pts" % [trick_name, trick_points]
	active_grinds[grind_id] = instance

func update_grind(grind_id: int, trick_name: String, trick_points: float) -> void:
	if active_grinds.has(grind_id):
		var instance = active_grinds[grind_id]
		if is_instance_valid(instance):
			instance.text = "%s  %d pts" % [trick_name, trick_points]
		else:
			active_grinds.erase(grind_id)

func clear_grinds() -> void:
	for instance in active_grinds.values():
		if is_instance_valid(instance):
			instance.queue_free()
	active_grinds.clear()

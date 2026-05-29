extends VBoxContainer

@export var trick_list: Control
var tricks = []
var max_points = 0
var points = 0
var is_grinding := false
var can_trick := false

func _ready() -> void:
	modulate.a = 0.0

func _process(delta: float):
	if points > max_points:
		max_points = points
	
	$"../ScoreTimer/Score".set_text("Max Score: " + str(int(max_points)))
	
	if points >= 1 or is_grinding:
		modulate.a = lerp(modulate.a, 1.0, delta * 10.0)
	else:
		modulate.a = lerp(modulate.a, 0.0, delta * 5.0)

func add_trick(trick_name: String, trick_points: float, repeating: bool):
	tricks.push_front({
		"trick": trick_name,
		"points": trick_points,
		"repeating": repeating
	})
	trick_list.add_trick(trick_name, trick_points)

func update_grind(grind_id: int, trick_name: String, trick_points: float):
	is_grinding = true
	for t in tricks:
		if t.has("grind_id") and t["grind_id"] == grind_id:
			var point_diff = trick_points - t["points"]  # only add the difference
			t["points"] = trick_points
			points += point_diff
			trick_list.update_grind(grind_id, trick_name, trick_points)
			return
	# New grind entry — add full points
	points += trick_points
	tricks.push_front({
		"trick": trick_name,
		"points": trick_points,
		"repeating": true,
		"grind_id": grind_id
	})
	trick_list.add_grind(grind_id, trick_name, trick_points)
	
func reset():
	tricks.clear()
	is_grinding = false

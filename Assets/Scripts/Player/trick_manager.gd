extends Node

# This code defines the way tricks will be handled and displayed in the screen

"""
	Trick Manager

	Trick manager is a script that will mainly define the way tricks and basic points will be taken
	by defining what tricks can be made, what is being done, and how much points it will generate
	either by second or by trick.
	
	The tricks types should be in a enum state, that will define on tricks a certain name and points
"""

enum TricksEnum {
	# Grinds
	None = -1,
	FrontGrind,
	SideGrind,
	BackGrind,
	LeftFlip,
	RightFlip,
	BackFlip,
	FrontFlip,
	Fall
}

# This function referenciates the 
const tricks = {
	TricksEnum.FrontGrind: {
		"label": "Grind",
		"points": 100
	},
	TricksEnum.SideGrind: {
		"label": "Side Grind",
		"points": 125
	},
	TricksEnum.BackGrind: {
		"label": "Back Grind",
		"points": 150
	},
	TricksEnum.LeftFlip: {
		"label": "Left Flip",
		"animation": "left_flip",
		"points": 120,
		"unique": true
	},
	TricksEnum.RightFlip: {
		"label": "Right Flip",
		"animation": "right_flip",
		"points": 120,
		"unique": true
	},
	TricksEnum.BackFlip: {
		"label": "Back Flip",
		"animation": "back_flip",
		"points": 120,
		"unique": true
	},
	TricksEnum.FrontFlip: {
		"label": "Front Flip",
		"animation": "front_flip",
		"points": 120,
		"unique": true
	},
	TricksEnum.Fall: {
		"fall": true
	}
}

var selected_trick = TricksEnum.None # This is the trick being done

var points = 0 # Completed Points
var added_points = 0 # Trick Points
var multiplier = 0

var tricks_list = []
var tricks_string = ""

@export var can_trick = true

var point_checker_scale = 0.0

# Functions:
	# - Setter and getter
	# - Display the trick name
	# - Display the trick points being taken

func _init() -> void:
	multiplier = 0

func set_trick(trick: TricksEnum):
	if trick == -1 or not can_trick:
		selected_trick = trick
		tricks_list = []
		tricks_string = ""
		added_points = 0
		multiplier = 0
		return

	# point_checker_scale = 1.0

	var animation_player = $"../AnimationManager"
	var trick_changed = (selected_trick != trick)
	selected_trick = trick

	if tricks[selected_trick].has("animation"):
		if trick_changed:
			animation_player.play(tricks[selected_trick].animation)
		else:
			animation_player.stop()
			animation_player.play(tricks[selected_trick].animation)

	if not tricks_list.has(tricks[selected_trick].label):
		multiplier += 1

	if tricks[selected_trick].has("unique"):
		tricks_list.append(tricks[selected_trick].label)
		added_points += tricks[selected_trick].points
		add_trick_string()
	else:
		if tricks_list.size() > 0:
			if tricks_list[tricks_list.size() - 1] != tricks[selected_trick].label:
				tricks_list.append(tricks[selected_trick].label)
				add_trick_string()
		else:
			tricks_list.append(tricks[selected_trick].label)
			add_trick_string()

func add_trick_string():
	if not tricks_string == "":
		tricks_string += " - "
	
	tricks_string += tricks[selected_trick].label

func get_trick():
	return selected_trick

func _process(delta: float) -> void:
	# const base = 0.5
	# point_checker_scale -= base * delta
	
	if point_checker_scale <= 0.0:
		point_checker_scale = 0.0
	
	$"../Ui".time_of_grace.scale.x = point_checker_scale
	
	if selected_trick != -1:
		# If the player failed
		if tricks[selected_trick].get("fall", false):
			selected_trick = null
		
		# If the player is doing t he correct trick
		if not tricks[selected_trick].has("unique"):
			added_points += tricks[selected_trick].points * delta
		$"../Ui".combo_tricks.set_text(tricks_string)
		$"../Ui".combo_points.set_text(str(multiplier) + "x " + str(int(added_points)))
		$"../Ui".combo_container.modulate.a = lerp($"../Ui".combo_container.modulate.a, 1.0, delta * 10.0)
	else:
		$"../Ui".combo_container.modulate.a = lerp($"../Ui".combo_container.modulate.a, 0.0, delta * 5.0)

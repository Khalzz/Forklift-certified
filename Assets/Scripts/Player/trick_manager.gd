extends Node

# This code defines the way tricks will be handled and displayed in the screen

"""
Todo: 
	- Add switches as tricks where if the player presses one key he will change
		his orientation instantly from advancing to going backwards

Remember dumbass the difference of concept between "Falling and landing"

This trick container should have an especific logic handling, this mainly is:
	- A combo is started once the player does one trick DONE
	- A trick is added to the combo once the player does another trick or lands DONE
		the trick with a "Connector trick" like:
			- Manuals, switches, or other tricks.
	- A combo is broken once the players fails to complete the execution of
		a trick or once he lands another trick withouc a connector trick

"""


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
@export var can_grind = true

var point_checker_scale = 0.0

var is_doing_trick = false
var trick_point_adding_flag = false
var landed = true

# Functions:
	# - Setter and getter
	# - Display the trick name
	# - Display the trick points being taken

func _init() -> void:
	multiplier = 0
	is_doing_trick = false
	

func set_trick(trick: TricksEnum):
	if trick == -1 or not can_trick:
		selected_trick = trick
		tricks_list = []
		tricks_string = ""
		added_points = 0
		multiplier = 0
		return

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
	$"../Ui".set_points(points) # Aprox them
	
	if selected_trick != -1:
		# This is not working for some reason, check why the player stills falls even after this being commented
		# if tricks[selected_trick].get("fall", false):
			#selected_trick = null
			
		if $"../StateMachine".is_touching_ground():
			failed_or_landed()
		
		# If the player is doing t he correct trick
		if tricks.has(selected_trick):
			if not tricks[selected_trick].has("unique"):
				added_points += tricks[selected_trick].points * delta
			$"../Ui".combo_tricks.set_text(tricks_string)
			$"../Ui".combo_points.set_text(str(multiplier) + "x " + str(int(added_points)))
			$"../Ui".combo_container.modulate.a = lerp($"../Ui".combo_container.modulate.a, 1.0, delta * 10.0)
	else:
		$"../Ui".combo_container.modulate.a = lerp($"../Ui".combo_container.modulate.a, 0.0, delta * 5.0)
		if trick_point_adding_flag:
			points += added_points * multiplier
			multiplier = 0
			added_points	 = 0
			trick_point_adding_flag = false
		
		
func failed_or_landed():
	trick_point_adding_flag = true
	selected_trick = -1

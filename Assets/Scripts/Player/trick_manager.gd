extends Node

enum TricksEnum {
	None = -1,
	FrontGrind, SideGrind, BackGrind,
	LeftFlip, RightFlip, BackFlip, FrontFlip,
	Fall
}

const TRICKS = {
	TricksEnum.FrontGrind: { "label": "Grind", "points": 200 },
	TricksEnum.SideGrind:  { "label": "Side Grind", "points": 200 },
	TricksEnum.BackGrind:  { "label": "Back Grind", "points": 200 },
	TricksEnum.LeftFlip:   { "label": "Left Flip",  "points": 120, "animation": "left_flip",  "unique": true },
	TricksEnum.RightFlip:  { "label": "Right Flip", "points": 120, "animation": "right_flip", "unique": true },
	TricksEnum.BackFlip:   { "label": "Back Flip",  "points": 120, "animation": "back_flip",  "unique": true },
	TricksEnum.FrontFlip:  { "label": "Front Flip", "points": 120, "animation": "front_flip", "unique": true },
	TricksEnum.Fall:       { "fall": true }
}

@export var can_trick = true

var selected_trick = TricksEnum.None
var points = 0
var active_grind_id := -1
var active_grind_points := 0.0

func set_trick(trick: TricksEnum) -> void:
	if not can_trick:
		return

	var data = TRICKS.get(trick, null)
	if data == null or data.has("fall"):
		selected_trick = TricksEnum.None
		return

	var is_unique = data.get("unique", false)
	var same_trick = (trick == selected_trick)
	selected_trick = trick

	if data.has("animation"):
		var anim = $"../AnimationManager"
		anim.stop()
		anim.play(data["animation"])

	if is_unique:
		$"../Ui".trick_manager.add_trick(data["label"], data["points"], false)
		$"../Ui".trick_manager.points += data["points"]
	else:
		if not same_trick:
			active_grind_id += 1
			active_grind_points = 0.0

func _process(delta: float) -> void:
	$"../Ui".trick_manager.can_trick = can_trick

	if $"../StateMachine".is_touching_ground():
		_on_land()
		return
	if selected_trick != TricksEnum.None:
		var data = TRICKS.get(selected_trick, null)
		if data and not data.get("unique", false):
			active_grind_points += data["points"] * delta
			$"../Ui".trick_manager.update_grind(active_grind_id, data["label"], active_grind_points)

func _on_land() -> void:
	if selected_trick != TricksEnum.None:
		$"../Ui".trick_manager.points += active_grind_points
	$"../Ui".trick_manager.is_grinding = false
	selected_trick = TricksEnum.None
	active_grind_points = 0.0
	active_grind_id = -1

func _on_fall() -> void:
	print("AHH")
	# Wipe everything
	$"../Ui".trick_manager.points = 0
	$"../Ui".trick_manager.reset()
	selected_trick = TricksEnum.None
	active_grind_points = 0.0
	active_grind_id = -1

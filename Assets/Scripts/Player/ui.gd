extends CanvasLayer

@export var state_label: Label
@export var can_grind_label: Label
@export var can_trick_label: Label
@export var spin_count: Control

# On screen labels
@export var points: Label
@export var combo_points: RichTextLabel
@export var combo_tricks: RichTextLabel
@export var	combo_container: Control

@export var grind_curve: Control

@onready var time_of_grace = $ComboContainer/ComboBoxContainer/TimeOfGrace/ColorRect
var points_setted = 0

func _process(delta: float) -> void:
	$Panel/MarginContainer/DebugLabels/Framerate.set_text(str(int(Engine.get_frames_per_second())) + " FPS")

func set_points(points_to_add):
	if points_setted != points_to_add:
		points_setted = points_to_add
		points.set_text(str("Points: " + str(points_setted)))
	

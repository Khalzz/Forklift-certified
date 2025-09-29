extends CanvasLayer

@export var state_label: Label
@export var can_grind_label: Label
@export var can_trick_label: Label

# On screen labels
@export var points: Label
@export var combo_points: RichTextLabel
@export var combo_tricks: RichTextLabel
@export var	combo_container: Control

@onready var time_of_grace = $ComboContainer/ComboBoxContainer/TimeOfGrace/ColorRect

func _process(delta: float) -> void:
	$Panel/MarginContainer/DebugLabels/Framerate.set_text(str(int(Engine.get_frames_per_second())) + " FPS")

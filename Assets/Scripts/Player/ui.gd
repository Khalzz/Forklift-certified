extends CanvasLayer

@export var state_label: Label
@export var can_grind_label: Label
@export var can_trick_label: Label
@export var speed: Label
@export var spin_count: Control
@export var direction_dot: Control
@export var framerate: Label

@export var trick_manager: Control

@export var grind_curve: Control

func _process(delta: float) -> void:
	framerate.set_text(str(int(Engine.get_frames_per_second())) + " FPS")

func falling():
	trick_manager.points = 0
	

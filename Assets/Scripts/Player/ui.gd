extends CanvasLayer

@export var state_label: Label
@export var can_grind_label: Label

func _process(delta: float) -> void:
	$Panel/MarginContainer/DebugLabels/Framerate.set_text(str(int(Engine.get_frames_per_second())) + " FPS")

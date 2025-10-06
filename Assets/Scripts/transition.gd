extends Control

func _ready() -> void:
	close()

func open():
	$AnimationPlayer.play("open")

func close():
	$AnimationPlayer.play("close")

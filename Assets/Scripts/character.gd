extends Sprite3D

@export var player: Node3D

func _process(delta: float) -> void:
	$".".look_at(player.camera.global_position)

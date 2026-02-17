extends Node3D

@export var player_model: Node3D
@export var sparks: Node3D

func stretch(delta, multiplier):
	player_model.scale = player_model.scale.lerp(Vector3(0.05, 0.15, 0.05), delta * multiplier)
	
func squash(delta, multiplier):
	player_model.scale = player_model.scale.lerp(Vector3(0.15, 0.05, 0.15), delta * multiplier)
	
func base(delta, multiplier):
	player_model.scale = player_model.scale.lerp(Vector3(0.1, 0.1, 0.1), delta * 5)

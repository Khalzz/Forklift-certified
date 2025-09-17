extends Node3D

@export var model: Node3D
@export var ground_ray: Node3D
@export var rigid_body: RigidBody3D
@export var ui: CanvasLayer

func stretch(delta, multiplier):
	model.scale = model.scale.lerp(Vector3(0.05, 0.15, 0.05), delta * multiplier)
	
func squash(delta, multiplier):
	model.scale = model.scale.lerp(Vector3(0.15, 0.05, 0.15), delta * multiplier)
	
func base(delta, multiplier):
	model.scale = model.scale.lerp(Vector3(0.1, 0.1, 0.1), delta * 5)
	

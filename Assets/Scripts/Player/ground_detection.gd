extends Node3D

func checking_floor(value):
	for child in get_children():
		child.enabled = value

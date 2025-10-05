extends Node

"""
	Controller Node
	
	Controller Node is a global implementation of a controller subsystem.
	
	Here we can define stuff like the values of sticks, button pressing and other
	elements about controllers that are logic relative.
"""

var l_stick = Vector2.ZERO
var r_stick = Vector2.ZERO

func _init() -> void:
	pass
	
func _process(delta: float) -> void:
	l_stick = Vector2(Input.get_axis("left", "right"), Input.get_axis("backward", "forward"))

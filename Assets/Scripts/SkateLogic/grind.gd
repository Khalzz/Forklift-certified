extends Path3D

@export var tag = ""
@export var loop = false
var path_follower = null

func _ready() -> void:
	path_follower = $PathFollower
	path_follower.loop = loop
	
	add_to_group("grindable")

extends Area3D
 
@export var base_player: Node3D
@export var state_machine: Node

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exit)
	
func _process(delta):
	pass
	
func _on_area_entered(area: Area3D):
	pass
	#base_player.actionable_grind = area

func _on_area_exit(area: Area3D):
	pass
	# if base_player.actionable_grind == area:
		# base_player.actionable_grind = null

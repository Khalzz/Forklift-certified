extends Control

@onready var path_follow = $MarginContainer/CenterContainer/CenterContainer/Path2D/PathFollow2D

@export var lowest_speed = 0.2
@export var fastest_speed = 1.0
@export var base_speed = 1.0

var should_fall = false
var multiplier = 1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if visible:
		$BalancingSelector.global_position = path_follow.global_position
		$BalancingSelector.global_rotation = path_follow.global_rotation
		
		var progress = path_follow.progress_ratio
		var dist_from_center = abs(progress - 0.5)
		var normalized_dist = dist_from_center / 0.5
		
		var speed_multiplier = lerp(lowest_speed, fastest_speed, normalized_dist)
		
		var move = base_speed * speed_multiplier * multiplier
		path_follow.progress_ratio += move * delta
		
		if Controller.l_stick.x < -0.5:
			multiplier = -1
		elif Controller.l_stick.x > 0.5:
			multiplier = 1
		
		if progress == 0.0 or progress == 1.0:
			should_fall = true

func start_grind():
	should_fall = false
	$".".visible = true
	path_follow.progress_ratio = 0.5
	var random_bool = randi() % 2 == 0
	
	if random_bool:
		multiplier = 1
	else:
		multiplier = -1
		
func stop_grind():
	$".".visible = false
	
	

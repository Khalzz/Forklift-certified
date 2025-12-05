extends Decal

var tyreMark = preload("res://Assets/Prefabs/Player/tyreMark.tscn")
var elapsed_time = 0.0
var fade_duration = 2.0  # Time to fade out in seconds
var wait_time = 5.0  # Time to wait before fading

func _process(delta: float) -> void:
	elapsed_time += delta
	
	# Wait 5 seconds before starting to fade
	if elapsed_time > wait_time:
		# Calculate fade progress (0 to 1)
		var fade_progress = (elapsed_time - wait_time) / fade_duration
		
		# Make it slowly disappear by reducing transparency
		modulate.a = 1.0 - fade_progress
		
		# Once fully invisible, remove from scene
		if modulate.a <= 0:
			queue_free()

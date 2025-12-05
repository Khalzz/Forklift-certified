extends RigidBody3D

func _ready() -> void:
	# Randomly set the spawn of elements by each element
	var children = $CratesStand.get_children()
	
	for floor in children:
		var random_value = randi_range(1, 2)
		
		
		# Create a random number between 1 and 2
			# If its 1 
				# i will add a single "Big Box" and rotate randomly based on the min and max angle of the big box
			# If its 2
				# i will add two single boxes and rotate them randomly based on max and min rotation

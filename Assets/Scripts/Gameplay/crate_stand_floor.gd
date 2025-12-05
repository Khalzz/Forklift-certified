extends Node3D

func _ready():
	var random_value = randi_range(1, 3)
	if random_value == 1:
		$MultipleCrate.visible = false
		$SingleCrate.visible = true
		randomly_rotate($SingleCrate)
	elif random_value == 2:
		$MultipleCrate.visible = true
		$SingleCrate.visible = false
		randomly_rotate($MultipleCrate)
	else:
		$MultipleCrate.visible = false
		$SingleCrate.visible = false

func randomly_rotate(crateComponent: Node3D):
	var crates = crateComponent.get_children()
	if crates.size() >= 1:
		var crate_to_hide = randi_range(1, 3)
		match crate_to_hide:
			1:
				$MultipleCrate/Crate_1.visible = false
				$MultipleCrate/Crate_2.visible = true
			2:
				$MultipleCrate/Crate_1.visible = true
				$MultipleCrate/Crate_2.visible = false
	
	for crate in crates:
		var random_value = randf_range(-9.0, 9.0)
		crate.rotate_y(deg_to_rad(random_value))
	

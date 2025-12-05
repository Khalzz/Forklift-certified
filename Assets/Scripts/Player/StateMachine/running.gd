extends State

var rng = RandomNumberGenerator.new()

var spark_counter = 0.0
var spark_max = 0.1
var sparks_images = []
var throttle_axis = 0.0
var virtual_throttle = 0.0

const max_speed = 10.0
var real_speed = 0.0

func _init() -> void:
	sparks_images.append("res://Assets/Sprites/sparks/Sparks.svg")
	sparks_images.append("res://Assets/Sprites/sparks/Sparks_2.svg")
	sparks_images.append("res://Assets/Sprites/sparks/Sparks_3.svg")

func _ready() -> void:
	await get_tree().physics_frame
	var parent_forward = -$"../..".global_transform.basis.z
	var parent_y_rotation = atan2(parent_forward.x, parent_forward.z)
	get_parent().rigid_body.rotation.y = parent_y_rotation

func update(delta: float):
	throttle_axis = Input.get_action_strength("r_trigger") - Input.get_action_strength("l_trigger")
	$"../..".base(delta, 10)

	if get_parent().is_touching_ground():
		if Input.is_action_pressed("jump"):
			$"../..".squash(delta, 50)
		if Input.is_action_just_released("jump"):
			$"../../Models/Sparks".visible = false
			get_parent().change_state(get_parent().States.Jumping)

func fixed_update(delta: float):
	if get_parent().rigid_body.linear_velocity.length() > 0.1:
		if get_parent().is_touching_ground():
			get_parent().rigid_body.angular_velocity.y = -(2.5 * get_parent().x_input)

	if get_parent().is_touching_ground() and get_parent().rigid_body.linear_velocity.length() > 0.1:
		var current_velocity = get_parent().rigid_body.linear_velocity
		var speed = current_velocity.length()
		var facing_direction = -get_parent().rigid_body.transform.basis.z

		var right_direction = get_parent().rigid_body.transform.basis.x
		var lateral_velocity = right_direction * current_velocity.dot(right_direction)

		var grip_strength = 2.0  # Adjust this value to control how grippy it feels
		get_parent().rigid_body.apply_central_force(-lateral_velocity * grip_strength)

	var angle = get_parent().rigid_body.transform.basis.z.angle_to(get_parent().rigid_body.linear_velocity.normalized())
	if angle > 0.5 and get_parent().is_touching_ground() and $"../../RigidBody".linear_velocity.length() > 1.0:
		handle_sparks(delta)
		$"../../Models/Sparks".visible = true
		$"../../Models/Sparks".scale = Vector3(rng.randf_range(1.0, 1.1),rng.randf_range(1.0, 1.1),rng.randf_range(1.0, 1.1))
	else:
		$"../../Models/Sparks".visible = false

	if throttle_axis > 0.1:
		real_speed = lerp(real_speed, max_speed, delta * 10.0)
		$"../../RigidBody".physics_material_override.friction = 0.7
		get_parent().rigid_body.apply_central_force(((get_parent().rigid_body.transform.basis.z) * real_speed) * throttle_axis)
	elif throttle_axis < -0.1:
		real_speed = 0.0
		$"../../RigidBody".physics_material_override.friction = 1.0
	else:
		real_speed = 0.0
		$"../../RigidBody".physics_material_override.friction = 0.1

	var z_speed = get_parent().rigid_body.linear_velocity.dot(get_parent().rigid_body.transform.basis.z)
	var x_speed = get_parent().rigid_body.linear_velocity.dot(get_parent().rigid_body.transform.basis.x)

func handle_sparks(delta):
	spark_counter += delta

	if spark_counter >= spark_max:
		spark_counter = 0.0
		for spark in $"../../Models/Sparks".get_children():
			if spark.has_method("set_texture"):
				var current_texture_path = spark.texture.resource_path if spark.texture else ""
				var new_texture_path = current_texture_path

				# Try to get a different texture
				while new_texture_path == current_texture_path and sparks_images.size() > 1:
					new_texture_path = sparks_images[rng.randi_range(0, sparks_images.size() - 1)]

				# Load and assign the texture
				var new_texture = load(new_texture_path)
				spark.texture = new_texture

	
	

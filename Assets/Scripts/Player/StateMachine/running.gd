extends State

@export var rigid_body: RigidBody3D
@export var models: Node3D
@export var ui: CanvasLayer

var rng = RandomNumberGenerator.new()

var spark_counter = 0.0
var spark_max = 0.1
var throttle_axis = 0.0
var virtual_throttle = 0.0

const max_speed = 10.0
var real_speed = 0.0

func _ready() -> void:
	await get_tree().physics_frame

func update(delta: float):
	throttle_axis = Input.get_action_strength("r_trigger") - Input.get_action_strength("l_trigger")
	models.base(delta, 10)

	if get_parent().is_touching_ground():
		if Input.is_action_pressed("jump"):
			models.squash(delta, 50)
		if Input.is_action_just_released("jump"):
			models.sparks.visible = false
			get_parent().change_state(get_parent().States.Jumping)

func fixed_update(delta: float):
	if get_parent().rigid_body.linear_velocity.length() > 0.1:
		if get_parent().is_touching_ground():
			# rigid_body.rotation.y -= (2.5 * Controller.l_stick.x) * delta
			rigid_body.angular_velocity.y = -(2.5 * Controller.l_stick.x)

	if get_parent().is_touching_ground() and get_parent().rigid_body.linear_velocity.length() > 0.1:
		var current_velocity = get_parent().rigid_body.linear_velocity
		var speed = current_velocity.length()
		var facing_direction = -get_parent().rigid_body.transform.basis.z

		var right_direction = get_parent().rigid_body.transform.basis.x
		var lateral_velocity = right_direction * current_velocity.dot(right_direction)

		var grip_strength = 2.0  # Adjust this value to control how grippy it feels
		get_parent().rigid_body.apply_central_force(-lateral_velocity * grip_strength)

	var angle = get_parent().rigid_body.transform.basis.z.angle_to(get_parent().rigid_body.linear_velocity.normalized())
	if angle > 0.5 and get_parent().is_touching_ground() and rigid_body.linear_velocity.length() > 1.0:
		models.sparks.visible = true
		models.sparks.scale = Vector3(rng.randf_range(1.0, 1.1),rng.randf_range(1.0, 1.1),rng.randf_range(1.0, 1.1))
	else:
		models.sparks.visible = false

	# Aparently if its < 0 its going forwards, else its going front
	var forward = rigid_body.global_transform.basis.z
	var dot_direction = rigid_body.linear_velocity.dot(forward)
	ui.direction_dot.set_text("Direction: " + str("%.2f" % dot_direction))

	if throttle_axis > 0.1:
		real_speed = lerp(real_speed, max_speed, delta * 10.0)
		rigid_body.physics_material_override.friction = 0.7
		get_parent().rigid_body.apply_central_force(((get_parent().rigid_body.transform.basis.z) * real_speed) * throttle_axis)
	elif throttle_axis < -0.1:
		if (dot_direction <= 0.0):
			real_speed = lerp(real_speed, max_speed, delta * 10.0)
			rigid_body.physics_material_override.friction = 0.7
			get_parent().rigid_body.apply_central_force(((get_parent().rigid_body.transform.basis.z) * real_speed) * throttle_axis)
		else:
			real_speed = 0.0
			rigid_body.physics_material_override.friction = 1.0
	else:
		real_speed = 0.0
		rigid_body.physics_material_override.friction = 0.1

	var z_speed = get_parent().rigid_body.linear_velocity.dot(get_parent().rigid_body.transform.basis.z)
	var x_speed = get_parent().rigid_body.linear_velocity.dot(get_parent().rigid_body.transform.basis.x)

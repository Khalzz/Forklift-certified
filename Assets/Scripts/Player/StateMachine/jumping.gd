extends State

var jump_strength = 3.5
var jumping = false

var can_check_ground = true
var can_jump = true
var jump_timer = 0.0
var max_jump_time = 0.2
var falling = false

var direction_count = 0.0

func start():
	get_parent().rigid_body.apply_impulse(Vector3.UP * jump_strength)
	jumping = true
	can_jump = false
	can_check_ground = false
	jump_timer = 0.0

	if get_parent().x_input > 0.5 or get_parent().x_input < -0.5:
		direction_count = 1.0
	else:
		direction_count = 0.0

func update(delta):
	if jumping:
		jump_timer += delta
		
		if jump_timer > max_jump_time:
			can_check_ground = true
	
	$"../..".stretch(delta, 50)
	
	if get_parent().is_touching_ground() and can_check_ground:
		$"../..".squash(delta, 150)
		get_parent().change_state(get_parent().States.Running)

func fixed_update(delta):
	if not jumping:
		jumping = true
		can_check_ground = false
	
	get_parent().rigid_body.apply_force(get_parent().rigid_body.linear_velocity.normalized() * 5.0)
	
	if (get_parent().x_input > 0.5 or get_parent().x_input < -0.5):
		direction_count += delta
		$"../../Ui".spin_count.set_text("%.2f" % direction_count)
		if direction_count >= 0.10:
			get_parent().rigid_body.rotation.y -= (10.0 * get_parent().x_input) * delta

extends State

@export var models: Node3D
@export var rigid_body: Node3D

var jump_strength = 5.0
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

	if Controller.l_stick.x > 0.5 or Controller.l_stick.x < -0.5:
		direction_count = 1.0
	else:
		direction_count = 0.0

func update(delta):
	if jumping:
		jump_timer += delta
		
		if jump_timer > max_jump_time:
			can_check_ground = true
	
	models.stretch(delta, 50)
	
	if get_parent().is_touching_ground() and can_check_ground:
		models.squash(delta, 150)
		#rigid_body.global_rotation.y = models.global_rotation.y
		#models.rotation.y = 0.0
		get_parent().change_state(get_parent().States.Running)

func fixed_update(delta):
	if not jumping:
		jumping = true
		can_check_ground = false
	
	if (Controller.l_stick.x > 0.5 or Controller.l_stick.x < -0.5):
		direction_count += delta
		$"../../Ui".spin_count.set_text("%.2f" % direction_count)
		if direction_count >= 0.10:
			print("Something here?")
			print(Controller.l_stick.x)
			rigid_body.rotation.y -= (10.0 * Controller.l_stick.x) * delta

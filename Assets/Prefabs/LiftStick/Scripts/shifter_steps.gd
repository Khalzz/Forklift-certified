extends Line2D

@export var shifter_stick: Node2D
var child_steps = []
var selected_step: Node2D = null
var last_r_stick = null

func _ready() -> void:
	child_steps = get_children()
	selected_step = child_steps[0]
	
	# Configure line appearance
	width = 40.0
	default_color = Color(0.0, 0.0, 0.0, 1.0)  # Bright redss
	z_index = 0
	
	# Draw lines between connected nodes
	draw_connections()

func draw_connections():
	clear_points()
	
	for step in child_steps:
		add_point(step.position)

func _process(delta: float) -> void:
	shifter_stick.global_position = lerp(shifter_stick.global_position, selected_step.global_position, delta * 10.0)
	
	if last_r_stick != Controller.r_stick:
		last_r_stick = Controller.r_stick
		print(Controller.r_stick)
	
	if Controller.r_stick.y < -0.5:
		if selected_step.bottom != null:
			selected_step = selected_step.bottom
	if Controller.r_stick.y > 0.5:
		if selected_step.top != null:
			selected_step = selected_step.top
	if Controller.r_stick.x < -0.5:
		if selected_step.left != null:
			selected_step = selected_step.left
	if Controller.r_stick.x > 0.5:
		if selected_step.right != null:
			selected_step = selected_step.right

extends Node

@export var base_player: Node3D

@export var ground_rays: Node3D
@export var rigid_body: RigidBody3D

@export var idle_node: Node
@export var jumping_node: Node
@export var running_node: Node
@export var falling_node: Node
@export var grinding_node: Node

@export var direction_arrow: Node

var floor_normals = null

enum States {
	Idle,
	Jumping,
	Running,
	Falling,
	Grinding
}


@onready var stateElements = {
	States.Idle: idle_node,
	States.Jumping: jumping_node,
	States.Running: running_node,
	States.Falling: falling_node,
	States.Grinding: grinding_node
}

var state = States.Idle
var newly_started = true

var is_grinding

# Controler
var x_input = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
var y_input = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

var xr_input = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
var yr_input = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

var grindable_states = [States.Idle, States.Jumping, States.Falling, States.Running]

var static_states = [States.Grinding]

func _process(delta: float) -> void:
	x_input = -Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	y_input = -Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)	
	xr_input = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	yr_input = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)	
	
	stateElements[state].update(delta)
	
	var grindables = $Grinding.get_grindables()
	
	if Array(grindables).size() > 0 and grindable_states.has(state):
		$Grinding.actionable_grind = $Grinding.get_closest_grind(grindables)
		
		if $Grinding.actionable_grind:
			var local_position = $Grinding.actionable_grind.to_local(rigid_body.global_position)
			var offset = $Grinding.actionable_grind.curve.get_closest_offset(local_position)
			$Grinding.actionable_grind.path_follower.progress = offset
		
		if Input.is_action_pressed("grind") and $Grinding.actionable_grind:
			change_state(States.Grinding)

func _physics_process(delta: float) -> void:
	var move_dir = rigid_body.linear_velocity.normalized()
	
	if not static_states.has(state):
		$"../Models".global_position = $"../RigidBody".global_position
		$"../Models".global_rotation = $"../RigidBody".global_rotation
	
	# var arrow_position = rigid_body.global_transform.origin + move_dir * 1.0
	# direction_arrow.position.x = arrow_position.x
	# direction_arrow.position.z = arrow_position.z
	
	var angle = atan2(move_dir.x, move_dir.z)
	direction_arrow.rotation.y = angle
	
	stateElements[state].fixed_update(delta)

func is_touching_ground() -> bool:
	var touching_ground = false

	for ray in ground_rays.get_children():
		if ray.is_colliding():
			touching_ground = true

	return touching_ground

func change_state(new_state):
	get_parent().ui.state_label.set_text("State: " + stateElements[new_state].name)
	stateElements[new_state].start()
	state = new_state
	

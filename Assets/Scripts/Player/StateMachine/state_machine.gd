extends Node

@export var base_player: Node3D

@export var ground_rays: Node3D
@export var rigid_body: RigidBody3D

@export var idle_node: Node
@export var jumping_node: Node
@export var running_node: Node
@export var falling_node: Node
@export var grinding_node: Node
@export var failing_node: Node

@export var direction_arrow: Node

var floor_normals = null

# This value is the posible state in a trick if true, the user will fall once it touches the ground
@export var danger_state = false

enum States {
	Idle,
	Jumping,
	Running,
	Falling,
	Grinding,
	Failing
}

@onready var stateElements = {
	States.Idle: idle_node,
	States.Jumping: jumping_node,
	States.Running: running_node,
	States.Falling: falling_node,
	States.Grinding: grinding_node,
	States.Failing: failing_node
}

@export var state = States.Idle
var newly_started = true

var is_grinding

# Controler
var x_input = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
var y_input = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

var xr_input = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
var yr_input = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

var grindable_states = [States.Idle, States.Jumping, States.Falling, States.Running]

var static_states = [States.Grinding]

func air_tricks():
	if (Input.is_action_just_pressed("flip") and x_input > 0.5) or (Input.is_action_just_pressed("flip") and x_input < 0.5 and x_input > -0.5 and y_input > -0.5 and y_input < 0.5 ):
		$"../TrickManager".set_trick($"../TrickManager".TricksEnum.LeftFlip)
	if Input.is_action_just_pressed("flip") and x_input < -0.5:
		#$"../AnimationManager".play("right_flip")
		$"../TrickManager".set_trick($"../TrickManager".TricksEnum.RightFlip)
	if Input.is_action_just_pressed("flip") and y_input < -0.5:
		#$"../AnimationManager".play("back_flip")
		$"../TrickManager".set_trick($"../TrickManager".TricksEnum.BackFlip)
	if Input.is_action_just_pressed("flip") and y_input > 0.5:
		#$"../AnimationManager".play("front_flip")
		$"../TrickManager".set_trick($"../TrickManager".TricksEnum.FrontFlip)


func _process(delta: float) -> void:
	x_input = -Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	y_input = -Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	xr_input = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	yr_input = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	stateElements[state].update(delta)
	
	if !is_touching_ground() and state != States.Grinding:
		air_tricks()
	
	$"../TrickManager".can_trick = !danger_state
	$"../Ui".can_trick_label.set_text("Can Trick: " + str($"../TrickManager".can_trick))
		
	if is_touching_ground() and danger_state:
		change_state(States.Failing)
	
	var grindables = $Grinding.get_grindables()
	
	if Array(grindables).size() > 0 and grindable_states.has(state) and !danger_state:
		$Grinding.actionable_grind = $Grinding.get_closest_grind(grindables)
		
		if $Grinding.actionable_grind:
			var local_position = $Grinding.actionable_grind.to_local(rigid_body.global_position)
			var offset = $Grinding.actionable_grind.curve.get_closest_offset(local_position)
			$Grinding.actionable_grind.path_follower.progress = offset
			
			if is_point_inside_capsule($Grinding.actionable_grind.path_follower.global_position, $"../RigidBody/GrindChecker/CollisionShape3D"):
				$"../GrindAble".global_position = $Grinding.actionable_grind.path_follower.global_position
				if Input.is_action_just_pressed("grind") and $Grinding.actionable_grind:
					change_state(States.Grinding)
		
			

func is_point_inside_capsule(point: Vector3, collision_shape: CollisionShape3D) -> bool:
	if not collision_shape.shape is CapsuleShape3D:
		return false
	
	var capsule = collision_shape.shape as CapsuleShape3D
	
	# Convert global point to local space of the capsule
	var local_point = collision_shape.global_transform.affine_inverse() * point
	
	var radius = capsule.radius
	var height_half = capsule.height * 0.5
	
	# Clamp Y to the cylindrical portion
	var clamped_y = clamp(local_point.y, -height_half, height_half)
	
	# Distance from the central axis (ignoring the clamped Y difference)
	var axis_distance = Vector2(local_point.x, local_point.z).length()
	
	# Distance from the closest point on the central axis
	var y_diff = local_point.y - clamped_y
	var total_distance = sqrt(axis_distance * axis_distance + y_diff * y_diff)
	
	return total_distance <= radius

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
	

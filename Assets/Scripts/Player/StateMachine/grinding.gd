extends State

var alignment = null
var grinding = false 

var grind_direction = null
var direction_to_face = Vector3.ZERO
var global_path_dir = Vector3.ZERO

var base_speed = 0.0

@export var rigidbody: RigidBody3D
@export var line_grind: MeshInstance3D

var grind_check_radius = 5.0

var actionable_grind = null

var path
var path_follower
var progress_ratio

var grind_speed = 0
var reverse = 1.0

var grind_angle = 0.0
var initial_velocity = Vector3.ZERO

var base_angle = 0.0
var backside = false

func _ready() -> void:
	rigidbody = $"../../RigidBody"
	$"../../Ui".grind_curve.stop_grind()

func start():
	path_follower = actionable_grind.path_follower
	path = actionable_grind
	progress_ratio = path_follower.progress_ratio
	grind_direction = null
	grinding = true
	base_angle = 0.0
	backside = false
	
	var path_dir: Vector3 = actionable_grind.path_follower.get_path_direction(
		actionable_grind.curve,
		path_follower.progress,
	)
	
	set_alignment()
	set_base_speed()
	
	var player_dir: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, $"../../Models".global_rotation.y)
	
	global_path_dir = actionable_grind.path_follower.get_path_direction(
		actionable_grind.curve,
		path_follower.progress,
	).normalized() * -alignment
	global_path_dir.y = 0
	player_dir.y = 0
	
	if global_path_dir.length() > 0 and player_dir.length() > 0:
		# Signed angle around Y axis
		var angle = atan2(
			global_path_dir.cross(player_dir).y, 
			global_path_dir.dot(player_dir)
		)
		
		var bearing = fmod(rad_to_deg(angle), 360.0)
		if bearing < 0:
			bearing += 360.0
		
		grind_angle = bearing
		
		var direction = global_path_dir.normalized()
		var target_position = $"../../Models".global_transform.origin + direction
	
	$"../../Ui".grind_curve.start_grind(true)
	
	var arrow = $"../../Direction"
	arrow.global_transform.origin = path_follower.global_transform.origin
	arrow.look_at(path_follower.global_transform.origin + global_path_dir, Vector3.UP)
	
	rigidbody.freeze = true
	initial_velocity = rigidbody.linear_velocity
	rigidbody.linear_velocity = Vector3(0.0, 0.0, 0.0)
	
	$"../../RigidBody/CollisionShape3D".disabled = true
	$"../../RigidBody/GroundRays".checking_floor(false)
	$"../../CameraSubsystem".set_followable($"../../Models")
	
	set_base_angle(grind_angle)

func set_base_angle(angle):
	if angle > 135 and angle < 225:
		backside = true
	
	if $"..".x_input < -0.5 and $"..".y_input > -0.5 and $"..".y_input < 0.5:
		base_angle = 90
	elif $"..".x_input > 0.5 and $"..".y_input > -0.5 and $"..".y_input < 0.5:
		base_angle = -90
		
func trick_definition(angle):
	var alignment_mod = -alignment
	
	if backside:
		alignment_mod = alignment
	
	$"../../Models".look_at(($"../../Models".global_transform.origin + global_path_dir * alignment_mod) , Vector3.UP)
	$"../../TrickManager".set_trick($"../../TrickManager".TricksEnum.FrontGrind)
	$"../../Models".rotate_y(deg_to_rad(base_angle))
	#$"../../Models".rotate_z(1.0)
	

func update(delta: float):
	$"../../Models".rotate_z(2.0 * delta)
	
	$"../..".base(delta, 100)
	
	if $"../../Ui".grind_curve.should_fall:
		end_grind()
		get_parent().change_state(get_parent().States.Failing)
	
	global_path_dir = actionable_grind.path_follower.get_path_direction(
		actionable_grind.curve,
		path_follower.progress,
	).normalized()
	
	move(delta)
	trick_definition(grind_angle)
	
	# Set positioning
	$"../../Models".global_position = path_follower.global_position
	rigidbody.linear_velocity.y = 0.0
	
	# Check if the grind ends, or the player jumps
	if Input.is_action_pressed("jump"): 
		$"../..".squash(delta, 50)
	if Input.is_action_just_released("jump"):
		end_grind()
		get_parent().change_state(get_parent().States.Jumping)
		
	check_fall()

func set_base_speed():
	# Get the actual horizontal speed magnitude
	var horizontal_velocity = Vector3(rigidbody.linear_velocity.x, 0, rigidbody.linear_velocity.z)
	var horizontal_speed = horizontal_velocity.length()
	
	# Store as absolute value - alignment handles direction in move()
	grind_speed = horizontal_speed

func move(delta):
	if not path_follower:
		return
	var path_dir: Vector3 = actionable_grind.path_follower.get_path_direction(
		actionable_grind.curve,
		path_follower.progress,
	).normalized()
	
	# Apply alignment to get directional speed
	var horizontal_speed = grind_speed * alignment
	
	var curve_length = actionable_grind.curve.get_baked_length()
	if curve_length == 0:
		return
	var progress_increment = (horizontal_speed * delta)
	
	path_follower.progress += progress_increment

	# Velocity follows the path direction with the aligned speed
	var velocity = path_dir * horizontal_speed
	velocity.y = 0

	rigidbody.linear_velocity = velocity

func end_grind():
	$"../../Models/Sparks".visible = false
	rigidbody.global_position = $"../../Models".global_position
	rigidbody.global_rotation = $"../../Models".global_rotation
	rigidbody.freeze = false
	$"../../RigidBody/CollisionShape3D".disabled = false
	$"../../RigidBody/GroundRays".checking_floor(true)
	$"../../CameraSubsystem".set_followable(rigidbody)
	$"../../Ui".grind_curve.stop_grind()

func check_fall():
	var length_grind = path.curve.get_baked_length()
	
	if !path.loop:
		if (alignment > 0 and path_follower.progress >= length_grind) or (alignment < 0 and path_follower.progress <= 0.0):
			end_grind()
			get_parent().change_state(get_parent().States.Running)
		
func get_grindables():
	var grindables = get_tree().get_nodes_in_group("grindable")
	var grind_areas = []
	
	debug($"../../RigidBody", grindables)
	
	for grindable in grindables:
		var distance_to_element = grindable.path_follower.global_position.distance_to($"../../RigidBody".global_position)
		
		# This should be between the grindable point and the player, not between the grindable OBJECT and player
		# if distance_to_element <= grind_check_radius:
		grind_areas.append(grindable)
	
	return grind_areas

func debug(rigidbody, grindables):
	var display = false
	
	if grindables.size() > 0:
		line_grind.mesh.clear_surfaces()
		line_grind.mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for grindable in grindables:
			var distance_to_element = grindable.path_follower.global_position.distance_to(rigidbody.global_position)
			if distance_to_element <= grind_check_radius:
				display = true
				line_grind.mesh.surface_add_vertex(rigidbody.global_transform.origin)
				line_grind.mesh.surface_add_vertex(grindable.path_follower.global_position)
	
		if display:
			line_grind.mesh.surface_end()

func get_closest_grind(grindables):
	var distance_flag = null
	var selected_grind = null
	
	for grindable in grindables:
		var local_position = grindable.to_local($"../../RigidBody".global_position)
		var offset = grindable.curve.get_closest_offset(local_position)
		grindable.path_follower.progress = offset
		
		var distance_to_element = grindable.path_follower.global_position.distance_to($"../../RigidBody".global_position)
		
		if distance_flag == null or distance_to_element < distance_flag:
			distance_flag = distance_to_element
			selected_grind = grindable
	
	if distance_flag and selected_grind and distance_flag <= grind_check_radius:
		return selected_grind
		
	return null

func set_alignment():
	if not actionable_grind:
		return
	
	var path_direction: Vector3 = actionable_grind.path_follower.get_path_direction(
		actionable_grind.curve, 
		actionable_grind.path_follower.progress, 
	).normalized()
	
	var player_direction: Vector3 = rigidbody.linear_velocity
	
	var player_direction_normalized = player_direction.normalized()
	var dot_result = path_direction.dot(player_direction_normalized)
	
	alignment = 1.0 if dot_result > 0 else -1.0
	grind_direction = atan2(path_direction.x, path_direction.z)

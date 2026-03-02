extends RigidBody3D

@export var player_model: Node3D
@export var player_direction: Node3D
@export var model_orientation: Node3D
@export var offset_distance := 0.5

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var velocity_xz = Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	if velocity_xz.length() > 0.01:
		var direction = velocity_xz.normalized()
		# Build basis: Y rotation from velocity, then apply X 90° on top using quaternions to avoid gimbal lock
		var y_quat = Quaternion(Vector3.UP, atan2(direction.x, direction.z))
		var x_quat = Quaternion(Vector3.RIGHT, PI / 2)
		var current_scale = player_direction.global_transform.basis.get_scale()

		var new_basis = Basis(y_quat * x_quat)
		new_basis = new_basis.scaled(current_scale)

		player_direction.global_transform.basis = new_basis

		# Offset position in velocity direction
		player_direction.global_position.x = global_position.x + direction.x * offset_distance
		player_direction.global_position.z = global_position.z + direction.z * offset_distance

	var model_forward = -player_model.global_transform.basis.z
	model_forward.y = 0
	
	if model_forward.length() > 0.01:
		var model_dir = model_forward.normalized()
		model_orientation.global_position.x = global_position.x - model_dir.x * offset_distance
		model_orientation.global_position.z = global_position.z - model_dir.z * offset_distance

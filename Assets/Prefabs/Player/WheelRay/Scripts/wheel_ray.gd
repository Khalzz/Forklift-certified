extends RayCast3D

@export_group("Generic values")
@export var rigid_body: RigidBody3D

@export_group("Wheel Setup")
@export var wheel_scale: float = 0.05
@export var wheel_offset: float = 0.0
@export var show_wheel = true
@export var directional_wheel = false
@export var rotation_multiplier = 1.0



@onready var wheel = $wheel

var wheel_half_height: float = 0.0

func _ready() -> void:
	wheel.visible = show_wheel
	wheel.scale = Vector3(wheel_scale, wheel_scale, wheel_scale)
	enabled = true
	
	# Calculate wheel height once
	var mesh_instance = wheel as MeshInstance3D
	if mesh_instance and mesh_instance.mesh:
		# Wait one frame for transforms to update
		await get_tree().process_frame
		
		var aabb = mesh_instance.mesh.get_aabb()
		var world_scale = wheel.global_transform.basis.get_scale()
		wheel_half_height = (aabb.size.y * world_scale.y) / 2.0

func _process(delta: float) -> void:
	if rigid_body:
		var speed = rigid_body.linear_velocity.length()
		wheel.rotation.x -= speed / (0.05 / 2) * delta
	
	if directional_wheel:
		wheel.rotation.y = lerp(wheel.rotation.y, 1.0 * Controller.l_stick.x * rotation_multiplier, delta * 5.0)

func _physics_process(delta: float) -> void:
	if wheel_half_height == 0.0:
		return
	
	if is_colliding():
		var collision_point = get_collision_point()
		var local_collision = to_local(collision_point)
		wheel.position = Vector3(wheel.position.x, local_collision.y + wheel_half_height + wheel_offset, wheel.position.z)
	else:
		wheel.position = Vector3(wheel.position.x, target_position.y + wheel_half_height - wheel_offset, wheel.position.z)

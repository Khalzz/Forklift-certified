extends Node3D

@export var rigidbody: RigidBody3D = null
@export var tire_width = 0.02
@export var min_distance = 0.05
@export var mark_lifetime = 10.0  # How long marks stay visible
@export var fade_duration = 2.0   # How long the fade takes

# Current trail being drawn
var current_trail: Dictionary = {}
var is_drawing = false
var last_point = Vector3.ZERO

# All active trails
var active_trails = []

func spawnMark(should_show):
	if should_show:
		if not is_drawing:
			start_new_trail()
		
		var current_pos = global_position
		
		if current_pos.distance_to(last_point) >= min_distance:
			add_point_to_current_trail(current_pos)
			last_point = current_pos
	else:
		if is_drawing:
			finish_current_trail()

func start_new_trail():
	print("Starting new trail")
	is_drawing = true
	last_point = global_position
	
	# Create a new trail mesh
	var trail_mesh = MeshInstance3D.new()
	trail_mesh.name = "TireMarkMesh_" + str(Time.get_ticks_msec())
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.086, 0.086, 0.086, 0.894)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail_mesh.material_override = material
	
	get_tree().current_scene.add_child(trail_mesh)
	
	# Store current trail data
	current_trail = {
		"mesh": trail_mesh,
		"points": [],
		"surface_tool": SurfaceTool.new(),
		"lifetime": 0.0,
		"fading": false
	}
	
	current_trail.surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

func add_point_to_current_trail(point: Vector3):
	if current_trail.is_empty():
		return
	
	current_trail.points.append(point)
	
	if current_trail.points.size() < 2:
		return
	
	rebuild_trail_mesh(current_trail)

func rebuild_trail_mesh(trail: Dictionary):
	var surface_tool = trail.surface_tool
	var points = trail.points
	var mesh_instance = trail.mesh
	
	if not mesh_instance or not mesh_instance.is_inside_tree():
		return
	
	surface_tool.clear()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	for i in range(points.size()):
		var point = points[i]
		
		# Get the rigidbody's Z-axis direction (front to back)
		var side_direction = Vector3.FORWARD
		if rigidbody:
			# Use the rigidbody's Z axis (rotated 90 degrees from X)
			side_direction = rigidbody.global_transform.basis.z.normalized()
		
		# Create width along the Z-axis (from -Z to +Z)
		var width_offset = side_direction * tire_width
		
		var uv_y = float(i) / max(1, points.size() - 1)
		
		# Add vertices from -Z to +Z
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(0, uv_y))
		surface_tool.add_vertex(point - width_offset)
		
		surface_tool.set_normal(Vector3.UP)
		surface_tool.set_uv(Vector2(1, uv_y))
		surface_tool.add_vertex(point + width_offset)
	
	mesh_instance.mesh = surface_tool.commit()

func finish_current_trail():
	print("Trail finished with ", current_trail.points.size(), " points")
	is_drawing = false
	
	if not current_trail.is_empty():
		# Add to active trails for lifetime management
		active_trails.append(current_trail)
		current_trail = {}

func _process(delta):
	# Update all active trails
	var trails_to_remove = []
	
	for i in range(active_trails.size()):
		var trail = active_trails[i]
		trail.lifetime += delta
		
		# Start fading after mark_lifetime
		if trail.lifetime >= mark_lifetime and not trail.fading:
			trail.fading = true
			trail.fade_start_time = trail.lifetime
		
		# Update fade
		if trail.fading:
			var fade_progress = (trail.lifetime - mark_lifetime) / fade_duration
			fade_progress = clamp(fade_progress, 0.0, 1.0)
			
			# Fade out the alpha
			var material = trail.mesh.material_override
			if material:
				var current_color = material.albedo_color
				current_color.a = lerp(0.894, 0.0, fade_progress)
				material.albedo_color = current_color
			
			# Mark for removal when fully faded
			if fade_progress >= 1.0:
				trails_to_remove.append(i)
	
	# Remove fully faded trails (iterate backwards to avoid index issues)
	for i in range(trails_to_remove.size() - 1, -1, -1):
		var index = trails_to_remove[i]
		var trail = active_trails[index]
		
		print("Removing trail: ", trail.mesh.name)
		trail.mesh.queue_free()
		active_trails.remove_at(index)

func end_trail():
	if is_drawing:
		finish_current_trail()

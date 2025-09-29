extends PathFollow3D
func get_path_direction(curve: Curve3D, offset: float) -> Vector3:
	var length = curve.get_baked_length()
	
	# Sample two points along the baked curve (local space)
	var delta = 0.1
	var local_p1 = curve.sample_baked(offset)
	var local_p2 = curve.sample_baked(offset + delta)
	
	# Handle case where we're near the end
	if offset + delta > length:
		local_p1 = curve.sample_baked(offset - delta)
		local_p2 = curve.sample_baked(offset)
	
	# Transform to global space
	var path_transform = get_parent().global_transform  # assuming parent is Path3D
	var global_p1 = path_transform * local_p1
	var global_p2 = path_transform * local_p2
	
	return (global_p2 - global_p1).normalized()

func get_path_rotation():
	return $"..".global_rotation

func get_global_direction(curve: Curve3D, offset: float) -> Vector3:
	return curve.sample_baked_with_rotation(offset).basis.z

extends PathFollow3D

func get_path_direction(curve: Curve3D, offset: float) -> Vector3:
	var length = curve.get_baked_length()
	var ratio = offset / length
	
	# get which segment we're in
	var point_count = curve.get_point_count()
	var seg = int(ratio * (point_count - 1))
	
	var p1 = curve.get_point_position(seg)
	var p2 = curve.get_point_position((seg + 1) % point_count)
	
	return (p2 - p1).normalized()

func get_global_direction(curve: Curve3D, offset: float) -> Vector3:
	return curve.sample_baked_with_rotation(offset).basis.z

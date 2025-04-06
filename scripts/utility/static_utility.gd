class_name StaticUtility

static func lerp_dampen(a : Variant, b : Variant, lambda : float, delta_time : float) -> Variant:
	return lerp(a, b, 1 - exp(-lambda * delta_time))

static func sample_sigmoid(x : float) -> float:
	return 1.0 / (1.0 + exp(-x))

static func sample_sigmoid_zero_one(x : float) -> float:
	return sample_sigmoid(x) * 2 - 1

static func rotate_towards(current : Vector3, target : Vector3, rotation_speed : float) -> Vector3:
	var cur_norm = current.normalized()
	var tar_norm = target.normalized()

	var cross = cur_norm.cross(tar_norm).normalized()
	var dot = cur_norm.dot(tar_norm)

	if cross.length() == 0.0:
		return current

	var angle = clamp(acos(dot), -rotation_speed, rotation_speed)

	return current.rotated(cross, angle) #Notice, this does not change the length of the vector

static func set_node_array_process_mode(node_array : Array[Node], new_process_mode) -> void:
	for node in node_array:
		node.process_mode = new_process_mode

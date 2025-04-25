extends Node

@export var position_node : Node3D = null
@export var control_node : Control = null
@export var size_ref_container : Container = null

func _process(_delta):
	var viewport_camera : Camera3D = get_viewport().get_camera_3d()
	var viewport_size : Vector2 = Vector2(get_viewport().get_visible_rect().size)
	var viewport_center : Vector2 = viewport_size / 2
	var is_behind : bool = viewport_camera.is_position_behind(position_node.global_position)
	var is_in_frustum : bool = viewport_camera.is_position_in_frustum(position_node.global_position)

	DebugDraw2D.set_text("CNP_PRE:", control_node.position)

	if is_in_frustum:
		control_node.position = viewport_camera.unproject_position(position_node.global_position)
	else:
		#Some smart ass guy from youtube is responsible for this code
		var local_to_camera : Vector3 = viewport_camera.to_local(position_node.global_position)
		var control_pos : Vector2 = Vector2(local_to_camera.x, -local_to_camera.y)
		if control_pos.abs().aspect() > viewport_center.aspect():
			control_pos *= viewport_center.x / abs(control_pos.x)
		else:
			control_pos *= viewport_center.y / abs(control_pos.y)
		control_node.set_global_position(viewport_center + control_pos)

	DebugDraw2D.set_text("CNP_POST:", control_node.position)
	DebugDraw2D.set_text("Is behind:", is_behind)
	DebugDraw2D.set_text("Is in frustum:", is_in_frustum)

	var hlaf_size_x : float = size_ref_container.size.x / 2
	var hlaf_size_y : float = size_ref_container.size.y / 2
	control_node.position.x = clamp(control_node.position.x, hlaf_size_x, viewport_size.x - hlaf_size_x)
	control_node.position.y = clamp(control_node.position.y, hlaf_size_y, viewport_size.y - hlaf_size_y)
extends Node

@export var position_node : Node3D = null
@export var control_node : Control = null

func _process(_delta):
	control_node.visible = not get_viewport().get_camera_3d().is_position_behind(position_node.global_position)
	control_node.position = get_viewport().get_camera_3d().unproject_position(position_node.global_position)
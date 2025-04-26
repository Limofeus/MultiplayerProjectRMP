extends Node

@export var spring_dampening : float = 1.0
@export var spring_freq : float = 10.0
@export var frustum_spring_freq : float = 20.0

@export var position_node : Node3D = null
@export var control_node : Control = null
@export var size_ref_container : Container = null

var is_in_frustum : bool = false
var target_x_pos : float = 0.0
var target_y_pos : float = 0.0

var x_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)
var y_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)

func _ready():
	calc_target_pos()
	x_spring.pos = target_x_pos
	y_spring.pos = target_y_pos

func _process(_delta):
	calc_target_pos()
	SpringUtility.UpdateSpring(x_spring, target_x_pos, _delta, frustum_spring_freq if is_in_frustum else spring_freq, spring_dampening)
	SpringUtility.UpdateSpring(y_spring, target_y_pos, _delta, frustum_spring_freq if is_in_frustum else spring_freq, spring_dampening)
	clamp_spring_pos() #since vel updates pos we have to clamp it

	control_node.position = Vector2(x_spring.pos, y_spring.pos)

func calc_target_pos():
	var target_pos : Vector2 = Vector2.ZERO

	var viewport_camera : Camera3D = get_viewport().get_camera_3d()
	var viewport_size : Vector2 = Vector2(get_viewport().get_visible_rect().size)
	var viewport_center : Vector2 = viewport_size / 2
	var is_behind : bool = viewport_camera.is_position_behind(position_node.global_position)

	is_in_frustum = viewport_camera.is_position_in_frustum(position_node.global_position)

	if is_in_frustum:
		target_pos = viewport_camera.unproject_position(position_node.global_position)
	else:
		#Some smart ass guy from youtube is responsible for this code
		var local_to_camera : Vector3 = viewport_camera.to_local(position_node.global_position)
		var control_pos : Vector2 = Vector2(local_to_camera.x, -local_to_camera.y)
		if control_pos.abs().aspect() > viewport_center.aspect():
			control_pos *= viewport_center.x / abs(control_pos.x)
		else:
			control_pos *= viewport_center.y / abs(control_pos.y)
		target_pos = (viewport_center + control_pos)

	var hlaf_size_x : float = size_ref_container.size.x / 2
	var hlaf_size_y : float = size_ref_container.size.y / 2
	target_x_pos = clamp(target_pos.x, hlaf_size_x, viewport_size.x - hlaf_size_x)
	target_y_pos = clamp(target_pos.y, hlaf_size_y, viewport_size.y - hlaf_size_y)


func clamp_spring_pos():
	var viewport_size : Vector2 = Vector2(get_viewport().get_visible_rect().size)
	var hlaf_size_x : float = size_ref_container.size.x / 2
	var hlaf_size_y : float = size_ref_container.size.y / 2
	x_spring.pos = clamp(x_spring.pos, hlaf_size_x, viewport_size.x - hlaf_size_x)
	y_spring.pos = clamp(y_spring.pos, hlaf_size_y, viewport_size.y - hlaf_size_y)
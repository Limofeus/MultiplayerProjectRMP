extends Node3D

@export var rescale_factor : float = 0.1

@export var move_dist_max : float = 0.1

@export var min_start_scale : float = 0.01
@export var max_start_scale : float = 0.2

@export var max_iters : int = 5

var cur_iters : int = 0

func _ready():
	var scale_x : float = randf_range(min_start_scale, max_start_scale)
	var scale_y : float = randf_range(min_start_scale, max_start_scale)
	var scale_z : float = randf_range(min_start_scale, max_start_scale)

	scale = Vector3(scale_x, scale_y, scale_z)

func update_iteration() -> void:
	cur_iters += 1

	var move_x : float = randf_range(-move_dist_max, move_dist_max)
	var move_y : float = randf_range(-move_dist_max, move_dist_max)
	var move_z : float = randf_range(-move_dist_max, move_dist_max)

	global_position += Vector3(move_x, move_y, move_z)
	scale += Vector3(rescale_factor, rescale_factor, rescale_factor)

	if (scale.x <= 0.0 or scale.y <= 0.0 or scale.z <= 0.0) or cur_iters >= max_iters:
		queue_free()
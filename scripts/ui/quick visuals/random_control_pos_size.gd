extends Control

@export var min_pos : Vector2
@export var max_pos : Vector2
@export var min_size : Vector2
@export var max_size : Vector2

func randomize():
	size = Vector2(randf_range(min_size.x, max_size.x), randf_range(min_size.y, max_size.y))
	position = Vector2(randf_range(min_pos.x, max_pos.x - size.x), randf_range(min_pos.y, max_pos.y - size.y))
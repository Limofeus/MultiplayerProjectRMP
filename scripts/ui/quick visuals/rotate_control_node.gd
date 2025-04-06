extends Control

@export var rotation_speed : float

func _process(delta):
	rotation += rotation_speed * delta
extends Node

@export var node_to_destroy : Node
@export var destroy_timer : float = 0.0

func _process(delta):
	destroy_timer -= delta
	if destroy_timer <= 0.0:
		node_to_destroy.queue_free()
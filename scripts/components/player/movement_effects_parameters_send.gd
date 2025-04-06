extends UnsyncedComponent

@export var player_body : CharacterBody3D

func _process(delta):
	unsynced_node.update_movement_effects(player_body.velocity, delta)
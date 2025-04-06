extends UnsyncedComponent

@export var player_body : CharacterBody3D

func _process(delta: float) -> void:
	unsynced_node.update_loaded_chunks(player_body.global_position)

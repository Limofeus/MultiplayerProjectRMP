extends Node3D

@export var entity_to_spawn : PackedScene

@export var default_entity_peer : int = 1

func _ready():
	NetworkManager.instance.player_scenes_created.connect(spawn_entity)

func spawn_entity() -> void:
	if multiplayer.get_unique_id() == default_entity_peer:
		StaticNetworkUtility.spatial_spawn_network_entity(entity_to_spawn, global_position, global_rotation)
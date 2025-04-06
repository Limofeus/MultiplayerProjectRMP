extends EntityComponent
class_name ComplexEntityChildSpawnComponent

@export var pivot_node : Node3D
@export var child_entity : PackedScene

func entity_ready() -> void:
	if network_entity.has_authority():
		NetworkSpawner.spawner_singleton.spawn_network_entity(child_entity, [ComplexParentSpawnArgument.new(pivot_node.get_path())])

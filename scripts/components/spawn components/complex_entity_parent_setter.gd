extends SpawnComponent
class_name ComplexEntityParentSetter

const PARENT_SET_CHANNEL = 0

@export var node_follow_component : NodeFollowComponent

func process_spawn_argument(spawn_argument : SpawnArgument) -> void:
	if spawn_argument is ComplexParentSpawnArgument:
		set_parent.rpc(spawn_argument.parent_path)

@rpc("reliable", "call_local", "any_peer", PARENT_SET_CHANNEL)
func set_parent(parent_path : NodePath) -> void:
	node_follow_component.target_node = get_node(parent_path)
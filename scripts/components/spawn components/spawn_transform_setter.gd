extends SpawnComponent
class_name SpawnTransformSetter

const TRANSFORM_SET_CHANNEL = 0

@export var positional_node : Node3D
@export var spwan_offset : Vector3 = Vector3.ZERO #Mostly for debugging

func process_spawn_argument(spawn_argument : SpawnArgument) -> void:
	if spawn_argument is PosRotSpawnArgument:
		set_pos_rot.rpc(spawn_argument.position, spawn_argument.rotation)

@rpc("reliable", "call_local", "any_peer", TRANSFORM_SET_CHANNEL)
func set_pos_rot(position : Vector3, rotation : Vector3) -> void:
	positional_node.global_position = position + spwan_offset
	positional_node.global_rotation = rotation

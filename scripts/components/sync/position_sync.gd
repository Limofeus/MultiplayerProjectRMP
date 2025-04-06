extends EntityComponent
class_name PositionSyncComponent

@export var node_to_sync : Node3D

func _process(delta):
	if network_entity.has_authority():
		position_sync_rpc.rpc(node_to_sync.position)

@rpc("authority", "call_remote", "unreliable_ordered")
func position_sync_rpc(new_position : Vector3)->void:
	node_to_sync.position = new_position

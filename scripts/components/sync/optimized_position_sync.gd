extends EntityComponent
class_name OptimizedPositionSyncComponent

#TODO: Low priority but position, rotation sync nodes can be done better I think (Also implement local / global / (maybe even relative) transform modes)

@export var node_to_sync : Node3D

var last_position : Vector3 = Vector3.ZERO

func _process(delta):
	if network_entity.has_authority():
		if last_position != node_to_sync.position:
			position_sync_rpc.rpc(node_to_sync.position)
		last_position = node_to_sync.position

@rpc("authority", "call_remote", "unreliable_ordered")
func position_sync_rpc(new_position : Vector3)->void:
	node_to_sync.position = new_position

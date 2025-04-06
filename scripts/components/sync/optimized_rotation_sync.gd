extends EntityComponent
class_name OptimizedRotationSyncComponent

@export var node_to_sync : Node3D

var last_rotation : Vector3 = Vector3.ZERO

func _process(delta):
	if network_entity.has_authority():
		if last_rotation != node_to_sync.global_rotation:
			rotation_sync_rpc.rpc(node_to_sync.global_rotation)
		last_rotation = node_to_sync.global_rotation

@rpc("authority", "call_remote", "unreliable_ordered")
func rotation_sync_rpc(new_rotation : Vector3)->void:
	node_to_sync.global_rotation = new_rotation
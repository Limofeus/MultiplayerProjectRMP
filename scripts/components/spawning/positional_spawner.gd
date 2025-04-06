extends EntityComponent
class_name PositionalSpawner

func spawn_entity(entity_to_spawn : PackedScene, spawn_position : Vector3, spawn_rotation : Vector3) -> void:
	if NetworkSpawner.spawner_singleton == null:
		print("Spawner singleton not found!")
		return

	var pos_rot_spawn_argument : PosRotSpawnArgument = PosRotSpawnArgument.new(spawn_position, spawn_rotation)
	NetworkSpawner.spawner_singleton.spawn_network_entity(entity_to_spawn, [pos_rot_spawn_argument])

	#Old approach, use spawn arguments instead
	#for entity_child in spawned_entity.get_children():
		#if entity_child is SpawnTransformSetter:
			#entity_child.set_pos_rot.rpc(spawn_position, spawn_quaternion)
			#return

class_name StaticNetworkUtility

static func get_network_entity_from_node(node : Node, must_be_interactable : bool = true) -> NetworkEntity:
	var entity_check : Node = node
	while entity_check != null and !(entity_check is InteractableNetworkEntity):
		entity_check = entity_check.get_parent()

	#This might look bad, but it works

	if entity_check is NetworkEntity:
		if must_be_interactable:
			if entity_check is InteractableNetworkEntity:
				return entity_check
			else:
				return null
		else:
			return entity_check
	else:
		print("No interactable entity found")
		return null

static func find_component_on_node(node : Node, component_type : Variant) -> Node: #Should not really be used
	var component : Node = null
	for child in node.get_children():
		if is_instance_of(child, component_type):
			component = child
			break
	return component

static func find_shared_component_on_entity(network_entity : NetworkEntity, component_type : Variant) -> Node:  #Note that only shared logic recieves interactions
	if network_entity == null:
		print("Network entity is null!")
		return null
	return find_component_on_node(network_entity.sharedLogic, component_type) #Change sharedLogic style BUMP

static func find_owner_component_on_entity(network_entity : NetworkEntity, component_type : Variant) -> Node:
	if network_entity == null:
		print("Network entity is null!")
		return null
	return find_component_on_node(network_entity.ownerLogic, component_type) #TODO: Change ownerLogic style BUMP

static func spatial_spawn_network_entity(entity_to_spawn : PackedScene, spawn_position : Vector3, spawn_rotation : Vector3) -> NetworkEntity:
	var pos_rot_spawn_argument : PosRotSpawnArgument = PosRotSpawnArgument.new(spawn_position, spawn_rotation)
	return NetworkSpawner.spawner_singleton.spawn_network_entity(entity_to_spawn, [pos_rot_spawn_argument])
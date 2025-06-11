extends Node
class_name NetworkEntity

@export var spawn_logic : Node
@export var ownerLogic : Node
@export var sharedLogic : Node #TODO: fix style (shared_logic), tho other scripts have to be changed as well

signal entity_ready
signal authority_changed

func emit_entity_ready() -> void: #should be called after the entity has been spawned and set up
	entity_ready.emit()

func get_desired_authority() -> int:
	return multiplayer.get_unique_id()

func fire_spawn_logic(spawn_arguments : Array[SpawnArgument]) -> void:
	if spawn_logic == null:
		return
	for spawn_logic_child in spawn_logic.get_children():
		if spawn_logic_child is SpawnComponent:
			spawn_logic_child.recieve_spawn_arguments(spawn_arguments)

func set_entity_authority(authority_to_set : int) -> void:
	set_multiplayer_authority(authority_to_set, true)
	if ownerLogic != null:
		if(has_authority()):
			ownerLogic.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			ownerLogic.process_mode = Node.PROCESS_MODE_DISABLED
	emit_authority_changed()

func emit_authority_changed() -> void:
	authority_changed.emit()

func get_current_authority() -> int:
	return get_multiplayer_authority()

func get_current_owner_index() -> int:
	var owner_index : int = NetworkManager.instance.peer_tracker.peer_ids.find(get_multiplayer_authority())
	if owner_index == -1:
		print("Owner not found")
	return owner_index

func has_authority() -> bool:
	return is_multiplayer_authority()

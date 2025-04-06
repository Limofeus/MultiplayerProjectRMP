extends EntityComponent
class_name OwnerChangeComponent

func set_new_owner_to_current_peer(force_change_owner : bool = false) -> void:
	set_new_owner(multiplayer.get_unique_id(), force_change_owner)

func set_new_owner(new_owner : int, force_change_owner : bool = false) -> void:
	
	#Do not change owner if new_owner is same as current
	if(new_owner == network_entity.get_current_authority()):
		return

	if(force_change_owner):
		change_owner(new_owner, true)
	else:
		print("CO: " + str(network_entity.get_current_authority()) + " NO: " + str(new_owner))
		safe_set_new_owner.rpc_id(network_entity.get_current_authority(), new_owner)

@rpc("reliable", "call_remote", "any_peer")
func safe_set_new_owner(new_owner : int):
	if(network_entity.has_authority()):
		change_owner(new_owner, true)

func change_owner(new_owner : int, propagate : bool = false) -> void:
	if !network_entity.has_authority() and propagate:
		print("Propagate changin owner on entity with no authority on peer " + str(multiplayer.get_unique_id()) + " !")

	network_entity.set_entity_authority(new_owner)

	if propagate:
		propagate_owner_change.rpc(new_owner)

@rpc("reliable", "call_remote", "any_peer")
func propagate_owner_change(new_owner : int) -> void:
	change_owner(new_owner, false)
extends InteractionReceivingComponent

@export var destruction_component : DestructionComponent
@export var force_destruction : bool = true

func recieve_interaction(interaction : Interaction, _interacted_entity : InteractableNetworkEntity) -> void:
	if interaction is EntityDestructionInteraction:

		if(force_destruction):
			destruction_component.destroy_entity(true) #Maybe make it true by default
		else:
			safe_destroy.rpc(network_entity.get_current_authority())

@rpc("reliable", "call_local", "any_peer")
func safe_destroy(): #Although theoretically this thing may JAM if authority is being changed while this happens (cus no peer would have authority over entity, so better to use force destroy)
	if(network_entity.has_authority()):
		destruction_component.destroy_entity(true)
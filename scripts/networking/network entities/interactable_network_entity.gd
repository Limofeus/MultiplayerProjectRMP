extends NetworkEntity
class_name InteractableNetworkEntity

@export var authority_interaction_priority : int = 0

#An interesting concept would be to put logic inside interactions (interaction.start_interaction(self, interacted_entity))

#PRIORITY CHECK INTERACTION, call with: network_entity.start_interaction(target_entity, interaction)

func start_interaction(interacted_entity : InteractableNetworkEntity, interaction : Interaction) -> void:
	
	if(!has_authority() and !interacted_entity.has_authority()):
		return

	if(has_authority() and interacted_entity.has_authority()):
		send_interaction(interacted_entity, interaction)
		
	#Interaction for objects handled by different peers
	else:
		if(has_authority() and check_if_peer_has_priority(interacted_entity, interaction)):
			send_interaction(interacted_entity, interaction)
		else:
			if(interacted_entity.has_authority() and !check_if_peer_has_priority(interacted_entity, interaction)):
				send_interaction(interacted_entity, interaction)

func check_if_peer_has_priority(interacted_entity : InteractableNetworkEntity, interaction : Interaction) -> bool:
	return authority_interaction_priority + interaction.authority_interaction_priority >= interacted_entity.authority_interaction_priority

#DIRECT INTERACTION, call with: network_entity.send_interaction(target_entity, interaction)

# start_interaction can be bypassed by using send_interaction, might be useful for callbacks
func send_interaction(interacted_entity : InteractableNetworkEntity, interaction : Interaction) -> void:
	interacted_entity.recieve_interaction(interaction, self)

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if sharedLogic == null:
		print("WARNING: No shared logic found on interactable entity, check " + str(self.name))
		return
	for shared_logic_child in sharedLogic.get_children():
		if shared_logic_child is InteractionRecievingComponent:
			print(self.get_current_authority())
			shared_logic_child.recieve_interaction(interaction, interacted_entity)

	#Propagation code was here, removed now
	#Propagate results after interaction in interaction recieving components (I think...)

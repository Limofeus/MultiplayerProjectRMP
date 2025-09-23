extends EntityComponent
class_name InteractionReceivingComponent

#It is not recommended to often use interacted_entity, as it can be null
func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	pass
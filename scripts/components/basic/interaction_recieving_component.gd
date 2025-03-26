extends EntityComponent
class_name InteractionRecievingComponent

#It is not recommended to often use interacted_entity, as it can be null
func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	pass
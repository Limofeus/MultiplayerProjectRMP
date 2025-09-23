extends FilteredMultibuttonInteractionProcessor
class_name OriginalActorMultibuttonInteractionProcessor

@export var entity_target : InteractableNetworkEntity = null
@export_group("Don't touch unless you know what you're doing :)")
@export var singular_component_interaction : InteractionReceivingComponent = null
@export var force_interaction : bool = true

func prepare_interaction(interacting_entity : InteractableNetworkEntity) -> Interaction:
	return null

func filtered_process_button_interaction(interacting_entity : InteractableNetworkEntity) -> void:
	print("continuing")
	var prepared_interaction : Interaction = prepare_interaction(interacting_entity)
	if prepared_interaction == null:
		return
	if singular_component_interaction == null:
		if force_interaction:
			interacting_entity.send_interaction(entity_target, prepared_interaction)
		else:
			interacting_entity.start_interaction(entity_target, prepared_interaction)
	else:
		singular_component_interaction.recieve_interaction(prepared_interaction, interacting_entity)
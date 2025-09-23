extends MultibuttonInteractionProcessor
class_name FilteredMultibuttonInteractionProcessor

@export var interaction_button_index : int = 0

func process_button_interaction(button_id : int, interacting_entity : InteractableNetworkEntity) -> void:
	if button_id != interaction_button_index:
		return
	else:
		filtered_process_button_interaction(interacting_entity)

func filtered_process_button_interaction(interacting_entity : InteractableNetworkEntity) -> void:
	pass
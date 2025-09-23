extends MultibuttonInteractionProcessor
class_name DebugMultibuttonInteractionProcessor

func process_button_interaction(button_id : int, interacting_entity : InteractableNetworkEntity) -> void:
	print("Button ", button_id, " was pressed by ", interacting_entity.name)

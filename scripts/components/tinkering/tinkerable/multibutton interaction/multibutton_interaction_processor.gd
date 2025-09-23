extends Node
class_name MultibuttonInteractionProcessor

#Add this as child of tinkerable multibutton and it'll catch it automatically
var tinkerable_multibutton : TinkerableMultibutton

func _ready():
	var parent = get_parent()
	if parent is TinkerableMultibutton:
		tinkerable_multibutton = parent
	else:
		print("ERR: Wrong button interaction processor parent")
	tinkerable_multibutton.button_interaction_completed.connect(process_button_interaction)

func process_button_interaction(button_id : int, interacting_entity : InteractableNetworkEntity) -> void:
	pass
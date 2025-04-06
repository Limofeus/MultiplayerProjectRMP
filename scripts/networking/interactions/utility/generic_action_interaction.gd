extends Interaction
class_name GenericActionInteraction

@export var action_string : String = ""

func _init(set_action_string : String = "", set_interaction_priority : int = 1):
	action_string = set_action_string
	authority_interaction_priority = set_interaction_priority
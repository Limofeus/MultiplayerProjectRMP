extends DialogueExternalAction
class_name DialogueOpenStore

func process_dialogue_action(action_name : String, sync_arguments : Array[Variant]) -> void:
	if action_name == "open_store":
		create_store(sync_arguments[0])

func create_store(store_model : Store):
	pass
extends DialogueWindowElement
class_name LabelChangeDialogueElement

@export var label_to_update : Label = null

func bound_entry_changed(new_value : Variant) -> void:
	if new_value is String:
		label_to_update.text = new_value
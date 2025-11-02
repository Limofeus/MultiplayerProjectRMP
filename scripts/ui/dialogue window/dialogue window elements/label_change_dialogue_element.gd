extends DialogueWindowElement
class_name LabelChangeDialogueElement

@export var label_to_update : Label = null
@export var ignore_null : bool = true

func bound_entry_changed(new_value : Variant) -> void:
	if (new_value == null || new_value == "" )&& ignore_null:
		return
	if new_value is String:
		label_to_update.text = new_value
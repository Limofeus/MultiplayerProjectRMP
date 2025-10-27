extends DialogueWindowElement
class_name TextureChangeDialogueElement

@export var texture_rect_to_update : TextureRect = null

func bound_entry_changed(new_value : Variant) -> void:
	if new_value is Texture2D:
		texture_rect_to_update.texture = new_value

	if new_value == null:
		texture_rect_to_update.texture = null

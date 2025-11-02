extends DialogueWindowElement
class_name TextureChangeDialogueElement

@export var texture_rect_to_update : TextureRect = null
@export var ignore_null : bool = true

func bound_entry_changed(new_value : Variant) -> void:
	if new_value is Texture2D:
		texture_rect_to_update.texture = new_value

	if new_value == null && !ignore_null:
		texture_rect_to_update.texture = null

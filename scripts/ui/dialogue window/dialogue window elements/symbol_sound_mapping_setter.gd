extends DialogueWindowElement

@export var default_symbol_sound_mapping : DialogueSymbolSoundsMapping = null

func _ready():
	dialogue_window_visual.text_processor.dialogue_symbol_sound_mapping = default_symbol_sound_mapping
	super()

func bound_entry_changed(_new_value : Variant) -> void:
	if dialogue_window_visual != null:
		dialogue_window_visual.text_processor.dialogue_symbol_sound_mapping = _new_value

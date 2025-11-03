extends DialogueWindowElement

@export var debug_ssm : DialogueSymbolSoundsMapping = null

func _ready():
	dialogue_window_visual.text_processor.dialogue_symbol_sound_mapping = debug_ssm#TODO: remove!

func bound_entry_changed(_new_value : Variant) -> void:
	if dialogue_window_visual != null:
		dialogue_window_visual.text_processor.dialogue_symbol_sound_mapping = _new_value

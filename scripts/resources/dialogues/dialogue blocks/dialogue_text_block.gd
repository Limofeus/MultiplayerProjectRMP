extends DialogueBlock
class_name DialogueTextBlock

@export_multiline var dialogue_text : String = ""

func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	dialogue_sequence.set_main_text(dialogue_text)
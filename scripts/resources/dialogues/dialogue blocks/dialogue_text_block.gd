extends DialogueBlock
class_name DialogueTextBlock

@export var dialogue_text : String = ""

func block_start():
	dialogue_sequence.set_main_text(dialogue_text)
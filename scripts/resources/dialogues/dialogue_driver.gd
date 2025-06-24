extends Resource
class_name DialogueDriver #Returns lines of dialogue and stuff probably

var current_dialogue_sequence : DialogueSequence
var current_dialogue_priority : int = 0

signal on_main_text_updated(main_text : String)
signal on_choice_options_updated(choice_option_strings : Array[String])
signal on_dialogue_metadata_updated(metadata : Dictionary)

func start_dialogue(dialogue_name : String, dialogue_priority : int) -> void:
	if dialogue_priority < current_dialogue_priority:
		return

	clean_current_dialogue_sequence()
	current_dialogue_sequence = DialogueSequencesLoaderInstance.get_dialogue_sequence(dialogue_name)
	current_dialogue_priority = dialogue_priority
	connect_to_cur_dialogue_sequence()
	current_dialogue_sequence.jump_start_at_block()

func connect_to_cur_dialogue_sequence() -> void:
	current_dialogue_sequence.on_main_text_updated.connect(main_text_updated)
	current_dialogue_sequence.on_choice_options_updated.connect(dialogue_choices_updated)
	current_dialogue_sequence.on_dialogue_metadata_updated.connect(dialogue_metadata_updated)

func clean_current_dialogue_sequence() -> void:
	if current_dialogue_sequence == null:
		return
	current_dialogue_sequence.on_main_text_updated.disconnect(main_text_updated)
	current_dialogue_sequence.on_choice_options_updated.disconnect(dialogue_choices_updated)
	current_dialogue_sequence.on_dialogue_metadata_updated.disconnect(dialogue_metadata_updated)
	current_dialogue_sequence = null
	current_dialogue_priority = 0

func main_text_updated(main_text : String) -> void:
	on_main_text_updated.emit(main_text)

func dialogue_choices_updated(choice_option_strings : Array[String]) -> void:
	on_choice_options_updated.emit(choice_option_strings)

func dialogue_metadata_updated(metadata : Dictionary) -> void:
	on_dialogue_metadata_updated.emit(metadata)
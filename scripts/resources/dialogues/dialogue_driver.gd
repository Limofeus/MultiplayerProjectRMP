extends Resource
class_name DialogueDriver #Returns lines of dialogue and stuff probably

var current_dialogue_sequence : DialogueSequence
var current_dialogue_priority : int = 0

var dialogue_parameters : Dictionary = {}

signal on_main_text_updated(main_text : String)
signal on_choice_options_updated(choice_option_strings : Array[String])
signal on_dialogue_metadata_updated(metadata : Dictionary)
signal on_dialogue_state_changed(dialogue_running : bool)

func connect_to_cur_dialogue_sequence() -> void:
	current_dialogue_sequence.on_main_text_updated.connect(main_text_updated)
	current_dialogue_sequence.on_choice_options_updated.connect(dialogue_choices_updated)
	current_dialogue_sequence.on_dialogue_metadata_updated.connect(dialogue_metadata_updated)
	current_dialogue_sequence.on_sequence_ended.connect(dialogue_sequence_ended)
	#TODO: Figure out a connection to dialogue ending

func clean_current_dialogue_sequence() -> void:
	if current_dialogue_sequence == null:
		return
	current_dialogue_sequence.on_main_text_updated.disconnect(main_text_updated)
	current_dialogue_sequence.on_choice_options_updated.disconnect(dialogue_choices_updated)
	current_dialogue_sequence.on_dialogue_metadata_updated.disconnect(dialogue_metadata_updated)
	current_dialogue_sequence.on_sequence_ended.disconnect(dialogue_sequence_ended)
	current_dialogue_sequence = null
	current_dialogue_priority = 0

func main_text_updated(main_text : String) -> void:
	on_main_text_updated.emit(main_text)

func dialogue_choices_updated(choice_option_strings : Array[String]) -> void:
	on_choice_options_updated.emit(choice_option_strings)

func dialogue_metadata_updated(metadata : Dictionary) -> void:
	on_dialogue_metadata_updated.emit(metadata)

func dialogue_sequence_ended() -> void:
	clean_current_dialogue_sequence()
	on_dialogue_state_changed.emit(false)

func update_sequence_parameters() -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.dialogue_parameters_changed(dialogue_parameters)

#ext functions

func start_dialogue(dialogue_name : String, dialogue_priority : int) -> void:
	if dialogue_priority <= current_dialogue_priority:
		return

	if current_dialogue_sequence != null:
		current_dialogue_sequence.end_sequence() #This in turn calls clean_current_dialogue_sequence via signals
	current_dialogue_sequence = DialogueSequencesLoaderInstance.get_dialogue_sequence(dialogue_name)
	current_dialogue_priority = dialogue_priority
	connect_to_cur_dialogue_sequence()
	current_dialogue_sequence.jump_start_at_block()
	on_dialogue_state_changed.emit(true)

func set_dialogue_parameter(key, value) -> void:
	dialogue_parameters[key] = value
	update_sequence_parameters()

func next_dialogue_block() -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.next_block() #Checks for block lock

func select_dialogue_choice(choice_index : int) -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.action_on_current_block("dialogue_choice_selected_" + str(choice_index))

func action_on_current_block(action_name : String) -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.action_on_current_block(action_name)

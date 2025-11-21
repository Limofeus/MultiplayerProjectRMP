extends Resource
class_name DialogueDriver #Returns lines of dialogue and stuff probably

var current_dialogue_sequence : DialogueSequence
var current_dialogue_priority : int = 0

var dialogue_metadata : Dictionary = {"target_lines" : 4, "text_type_speed_multiplier" : 1, "speaker_name" : ""} #Add another way to get default values?
var dialogue_parameters : Dictionary = {} #Maybe need to sync parameters instead???

signal on_main_text_updated(main_text : String)
signal on_choice_options_updated(choice_option_strings : Array[String])
signal on_dialogue_metadata_updated(metadata : Dictionary)
signal on_call_external_action(action_name : String, sync_arguments : Array[Variant])

signal on_dialogue_state_changed(dialogue_running : bool)

signal sync_dialogue_block(dialogue_sequence_name : String, block_index : int, sync_parameters : Dictionary) #TODO: Implement dialogue action syncing?..

func connect_to_cur_dialogue_sequence() -> void:
	current_dialogue_sequence.on_main_text_updated.connect(main_text_updated)
	current_dialogue_sequence.on_choice_options_updated.connect(dialogue_choices_updated)
	current_dialogue_sequence.on_dialogue_metadata_updated.connect(dialogue_metadata_updated)
	current_dialogue_sequence.on_sequence_ended.connect(dialogue_sequence_ended)
	current_dialogue_sequence.on_call_external_action.connect(call_external_action)
	
	current_dialogue_sequence.sync_dialogue_block_request.connect(emit_dialogue_sync_request.bind(current_dialogue_sequence.sequence_name))
	current_dialogue_sequence.sync_dialogue_end_request.connect(emit_dialogue_end_sync_request)

	#TODO: Figure out a connection to dialogue ending

func clean_current_dialogue_sequence() -> void:
	if current_dialogue_sequence == null:
		return
	current_dialogue_sequence.on_main_text_updated.disconnect(main_text_updated)
	current_dialogue_sequence.on_choice_options_updated.disconnect(dialogue_choices_updated)
	current_dialogue_sequence.on_dialogue_metadata_updated.disconnect(dialogue_metadata_updated)
	current_dialogue_sequence.on_sequence_ended.disconnect(dialogue_sequence_ended)
	current_dialogue_sequence.on_call_external_action.disconnect(call_external_action)

	current_dialogue_sequence.sync_dialogue_block_request.disconnect(emit_dialogue_sync_request)
	current_dialogue_sequence.sync_dialogue_end_request.disconnect(emit_dialogue_end_sync_request)

	current_dialogue_sequence = null
	current_dialogue_priority = 0

func main_text_updated(main_text : String) -> void:
	on_main_text_updated.emit(main_text)

func dialogue_choices_updated(choice_option_strings : Array[String]) -> void:
	on_choice_options_updated.emit(choice_option_strings)

func dialogue_metadata_updated(metadata : Dictionary) -> void:
	merge_update_dialogue_metadata(metadata)

func merge_update_dialogue_metadata(metadata : Dictionary) -> void:
	dialogue_metadata.merge(metadata, true)
	on_dialogue_metadata_updated.emit(dialogue_metadata)

func dialogue_sequence_ended() -> void:
	clean_current_dialogue_sequence()
	on_dialogue_state_changed.emit(false)

func call_external_action(action_name : String, sync_arguments : Array[Variant]) -> void:
	on_call_external_action.emit(action_name, sync_arguments)

func update_sequence_parameters() -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.dialogue_parameters_changed(dialogue_parameters)

func compose_relevant_parameter_dictionary(force_sync_parameter_keys : Array) -> Dictionary:
	var sync_parameters_dict : Dictionary = {}
	for parameter_key in force_sync_parameter_keys:
		sync_parameters_dict[parameter_key] = dialogue_parameters[parameter_key]
	return sync_parameters_dict

func emit_dialogue_sync_request(block_index : int, force_sync_parameter_keys : Array, seq_name : String) -> void:
	print("|DI SI| Emitting sync request for block " + str(block_index) + " in sequence " + seq_name + " with param_keys: " + str(force_sync_parameter_keys))
	sync_dialogue_block.emit(seq_name, block_index, compose_relevant_parameter_dictionary(force_sync_parameter_keys))

func emit_dialogue_end_sync_request(force_sync_parameter_keys : Array) -> void:
	sync_dialogue_block.emit("", -1, compose_relevant_parameter_dictionary(force_sync_parameter_keys)) #Int num doesn't matter here actually, doesn't get transferred anyway

func sync_dialogue(dialogue_sequence_name : String, dialogue_priority : int, block_index : int, force_sync_parameters : Dictionary) -> void:
	print("|DI SI| Received sync request for block " + str(block_index) + " in sequence " + dialogue_sequence_name + " with arguments: " + str(force_sync_parameters))
	if dialogue_sequence_name == "":
		pass #use this to pass dialogue end info?..
	elif current_dialogue_sequence == null or current_dialogue_sequence.sequence_name != dialogue_sequence_name:
		force_start_dialogue(dialogue_sequence_name, dialogue_priority, block_index, force_sync_parameters)
	else:
		current_dialogue_sequence.sync_dialogue_block(block_index, dialogue_parameters, force_sync_parameters)

func sync_end_dialogue(force_sync_parameters : Dictionary) -> void: 
	if current_dialogue_sequence != null:
		current_dialogue_sequence.end_sequence(false) #NOTICE: Look in to end_seq todo to see what to do with force sync params

#ext functions

func start_dialogue(dialogue_name : String, dialogue_priority : int) -> void:
	print("Dialogue driver START: ", dialogue_name)
	if dialogue_priority <= current_dialogue_priority:
		return
	force_start_dialogue(dialogue_name, dialogue_priority)

func force_start_dialogue(dialogue_name : String, dialogue_priority : int = 0, starting_block : int = 0, override_parameters : Dictionary = {}) -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.end_sequence() #This in turn calls clean_current_dialogue_sequence via signals

	current_dialogue_priority = dialogue_priority

	#For easier sync, maybe wrap in some func later
	var new_dialogue_parameters : Dictionary = dialogue_parameters.duplicate()
	new_dialogue_parameters.merge(override_parameters, true)

	current_dialogue_sequence = DialogueSequencesLoaderInstance.get_dialogue_sequence(dialogue_name)
	connect_to_cur_dialogue_sequence()
	dialogue_metadata_updated({})
	current_dialogue_sequence.jump_start_at_block(starting_block, new_dialogue_parameters)
	on_dialogue_state_changed.emit(true)

func set_dialogue_parameter(key, value) -> void:
	dialogue_parameters[key] = value
	print("Dialogue parameters in driver changed: ", dialogue_parameters)
	update_sequence_parameters()

func next_dialogue_block() -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.next_block(dialogue_parameters) #Checks for block lock

func select_dialogue_choice(choice_index : int) -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.action_on_current_block("dialogue_choice_selected_" + str(choice_index), dialogue_parameters)

func action_on_current_block(action_name : String) -> void:
	if current_dialogue_sequence != null:
		current_dialogue_sequence.action_on_current_block(action_name, dialogue_parameters)
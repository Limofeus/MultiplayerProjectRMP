extends Resource
class_name DialogueSequence

@export var sequence_name : String = ""
@export var sequence_lang_key : String = "en"
@export var dialogue_blocks : Array[DialogueBlock] = []

var current_block : DialogueBlock = null
var current_block_index : int = 0

signal on_choice_options_updated(choice_option_strings : Array[String])
signal on_main_text_updated(main_text : String)
signal on_dialogue_metadata_updated(metadata : Dictionary) #Like speaker name, text style, etc.
signal on_call_external_action(action_name : String, sync_arguments : Array[Variant])
signal on_sequence_ended()

signal sync_dialogue_block_request(block_index : int, sync_arguments : Array)
signal sync_dialogue_action(block_index : int, action_name : String, sync_arguments : Array) #Not yet implemented
signal sync_dialogue_parameters_change(block_index : int, sync_arguments : Array) #Not implemented yet
signal sync_dialogue_end_request()
#TODO: Idk, implement the action and param sync maybe

func init_sequence(dialogue_parameters : Dictionary = {}) -> void:
	#Probably clone resource before calling
	var godot_cant_cast_empty_array_to_empty_string_array_so_i_have_to_do_it_like_this : Array[String] = []
	on_choice_options_updated.emit(godot_cant_cast_empty_array_to_empty_string_array_so_i_have_to_do_it_like_this) #Reeemeemberr mee~~
	for block in dialogue_blocks:
		block.dialogue_sequence = self
		block.init_block(dialogue_parameters)

func jump_start_at_block(block_index : int = 0, dialogue_parameters : Dictionary = {}) -> void:
	init_sequence(dialogue_parameters)
	jump_to_block(block_index, dialogue_parameters)

func jump_to_block(block_index : int, dialogue_parameters : Dictionary = {}, sync_pass : bool = true) -> void:
	var previous_block_sync_keys : Array = []
	if current_block != null:
		previous_block_sync_keys = current_block.sync_parameter_keys()
		current_block.block_end(dialogue_parameters) #TODO: maybe pass "sync_pass" here and maybe to other functions as well idk

	if block_index >= dialogue_blocks.size():
		print("ERROR: Invalid block index")
		return

	current_block_index = block_index
	current_block = dialogue_blocks[current_block_index]

	if current_block.requires_sync() and sync_pass:
		sync_dialogue_block_request.emit(current_block_index, StaticUtility.merge_arrays(previous_block_sync_keys, current_block.sync_parameter_keys()))

	current_block.block_start(dialogue_parameters, sync_pass) # Раньше была на 4 строчки выше.. хз вроде так бага одного нету, так что пока пусть тут побудет


func sync_dialogue_block(block_index : int, dialogue_parameters : Dictionary, sync_parameters : Dictionary = {}) -> void:
	var synced_parameter_dict = dialogue_parameters.duplicate()
	synced_parameter_dict.merge(sync_parameters, true) #Merge with override
	jump_to_block(block_index, synced_parameter_dict, false)

#NOTICE maybe move next block logic in to dialogue block itself, it'll just get id's from sequence and stuff (Also no need to check for lock this way, it'll depend on the block)
func next_block(dialogue_parameters : Dictionary = {}) -> void:
	if current_block != null:
		if current_block.lock_next_block(dialogue_parameters):
			return

	if current_block_index + 1 >= dialogue_blocks.size():
		end_sequence()
	else:
		jump_to_block(current_block_index + 1, dialogue_parameters)

func clean_sequence() -> void:
	if current_block != null:
		current_block.block_end()
		current_block = null
		current_block_index = 0

func end_sequence(allow_sync : bool = true) -> void: #TODO: Look in to adding dialogue parameters in to all of those functions (too lazy to do this all now, no dialogue blocks use dialogue parameters now anyway)
	clean_sequence()
	if allow_sync:
		var curr_relevant_param_keys : Array = []
		if current_block != null:
			curr_relevant_param_keys = current_block.sync_parameter_keys()
		sync_dialogue_end_request.emit(curr_relevant_param_keys)
	on_sequence_ended.emit()

#Requests called from dialogue driver
func action_on_current_block(action_name : String, dialogue_parameters : Dictionary = {}) -> void:
	if current_block != null:
		current_block.block_action(action_name, dialogue_parameters)

		if current_block.requires_action_sync():
			sync_dialogue_action.emit(current_block_index, action_name, current_block.sync_parameter_keys())

func dialogue_parameters_changed(new_dialogue_parameters : Dictionary = {}) -> void:
	for block in dialogue_blocks:
		var is_current_block : bool = block == current_block
		block.dialogue_parameters_changed(new_dialogue_parameters, is_current_block)

		if block.requires_parameter_sync() == DialogueBlock.ParameterSyncType.DISABLED:
			return
		elif block.requires_parameter_sync() == DialogueBlock.ParameterSyncType.ALWAYS:
			sync_dialogue_parameters_change.emit(current_block_index, block.sync_parameter_keys())
		elif block.requires_parameter_sync() == DialogueBlock.ParameterSyncType.WHEN_CURRENT_BLOCK and is_current_block:
			sync_dialogue_parameters_change.emit(current_block_index, block.sync_parameter_keys())

#Requests called from blocks
func set_choice_options(choice_option_strings : Array[String]) -> void:
	on_choice_options_updated.emit(choice_option_strings)

func set_main_text(main_text : String) -> void:
	on_main_text_updated.emit(main_text)

func set_dialogue_metadata(metadata : Dictionary) -> void:
	on_dialogue_metadata_updated.emit(metadata)

func call_external_action(action_name : String, sync_arguments : Array[Variant]) -> void:
	on_call_external_action.emit(action_name, sync_arguments)
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
signal on_sequence_ended()

func init_sequence(dialogue_parameters : Dictionary = {}) -> void:
	#Probably clone resource before calling
	var godot_cant_cast_empty_array_to_empty_string_array_so_i_have_to_do_it_like_this : Array[String] = []
	on_choice_options_updated.emit(godot_cant_cast_empty_array_to_empty_string_array_so_i_have_to_do_it_like_this) #Reeemeemberr mee~~
	for block in dialogue_blocks:
		block.dialogue_sequence = self
		block.init_block(dialogue_parameters)

func jump_start_at_block(block_index : int = 0, dialogue_parameters : Dictionary = {}) -> void:
	init_sequence(dialogue_parameters)
	jump_to_block(block_index)

func jump_to_block(block_index : int, dialogue_parameters : Dictionary = {}) -> void:
	if current_block != null:
		current_block.block_end(dialogue_parameters)

	if block_index >= dialogue_blocks.size():
		print("ERROR: Invalid block index")
		return

	current_block_index = block_index
	current_block = dialogue_blocks[current_block_index]
	current_block.block_start(dialogue_parameters)

#NOTICE maybe move next block logic in to dialogue block itself, it'll just get id's from sequence and stuff (Also no need to check for lock this way, it'll depend on the block)
func next_block(dialogue_parameters : Dictionary = {}) -> void:
	if current_block != null:
		if current_block.lock_next_block(dialogue_parameters):
			return

	if current_block_index + 1 >= dialogue_blocks.size():
		end_sequence()
	else:
		jump_to_block(current_block_index + 1)

func clean_sequence() -> void:
	if current_block != null:
		current_block.block_end()
		current_block = null
		current_block_index = 0

func end_sequence() -> void:
	clean_sequence()
	on_sequence_ended.emit()

#Requests called from dialogue driver
func action_on_current_block(action_name : String, dialogue_parameters : Dictionary = {}) -> void:
	if current_block != null:
		current_block.block_action(action_name, dialogue_parameters)

func dialogue_parameters_changed(new_dialogue_parameters : Dictionary = {}) -> void:
	for block in dialogue_blocks:
		block.dialogue_parameters_changed(new_dialogue_parameters)

#Requests called from blocks
func set_choice_options(choice_option_strings : Array[String]) -> void:
	on_choice_options_updated.emit(choice_option_strings)

func set_main_text(main_text : String) -> void:
	on_main_text_updated.emit(main_text)

func set_dialogue_metadata(metadata : Dictionary) -> void:
	on_dialogue_metadata_updated.emit(metadata)
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

func init_sequence() -> void:
	#Probably clone resource before calling
	for block in dialogue_blocks:
		block.dialogue_sequence = self
		block.init_block()

func jump_start_at_block(block_index : int = 0) -> void:
	init_sequence()
	jump_to_block(block_index)

func jump_to_block(block_index : int) -> void:
	if current_block != null:
		current_block.block_end()
	if block_index >= dialogue_blocks.size():
		print("ERROR: Invalid block index")
		return
	current_block_index = block_index
	current_block = dialogue_blocks[current_block_index]
	current_block.block_start()

func next_block() -> void:
	if current_block_index + 1 >= dialogue_blocks.size():
		end_sequence()
	else:
		jump_to_block(current_block_index + 1)

func end_sequence() -> void:
	if current_block != null:
		current_block.block_end()
	current_block = null
	current_block_index = 0

	on_sequence_ended.emit()

#Requests called from blocks
func set_choice_options(choice_option_strings : Array[String]) -> void:
	on_choice_options_updated.emit(choice_option_strings)

func set_main_text(main_text : String) -> void:
	on_main_text_updated.emit(main_text)

func set_dialogue_metadata(metadata : Dictionary) -> void:
	on_dialogue_metadata_updated.emit(metadata)
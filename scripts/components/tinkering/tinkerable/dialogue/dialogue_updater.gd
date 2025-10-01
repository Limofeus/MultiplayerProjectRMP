extends EntityComponent
class_name TinkerableDialogueUpdater

@export var dialogue_triggers : Array[DialogueTrigger]
@export_group("Node References")
@export var tinkerable_dialogue : TinkerableDialogue = null
@export var dialogue_window : DialogueWindowVisual = null
@export var world_based_alter : WorldBasedControlAlter = null
@export var unfocused_skip_line_timer : Timer = null
var dialogue_driver : DialogueDriver = DialogueDriver.new()

var sync_cached_sequence_name : String = "" #Used to optimize packets a bit, in case of any bugs, just send seq name in every packet and deprecate this

func _ready() -> void:
	print("PAR: ", get_parent().name, " READY")
	#TINKERABLE & CONTROL ALTER
	tinkerable_dialogue.buttons_updated.connect(update_buttons)
	#idk, maybe change this later, depending on what the view needs / capable of (Responsible for dialogue display while other peer is chatting with npc)
	tinkerable_dialogue.on_tinkerable_state_changed.connect(calc_set_dialogue_visibility.unbind(1))
	tinkerable_dialogue.tinkerer_changed.connect(tinkerer_changed)
	tinkerable_dialogue.selection_changed.connect(dialogue_window.select_choise_option)
	tinkerable_dialogue.main_tinker_action_no_choice.connect(next_dialogue_block)

	world_based_alter.scale_mod_change.connect(dialogue_window.set_scale_alpha_multiplier)
	
	set_visibility_state(tinkerable_dialogue.current_tinkerable_state)

	dialogue_driver.on_choice_options_updated.connect(tinkerable_dialogue.update_dialogue_options)
	dialogue_driver.on_main_text_updated.connect(main_text_updated)

	dialogue_driver.on_dialogue_state_changed.connect(dialogue_state_changed)
	dialogue_driver.on_dialogue_metadata_updated.connect(dialogue_metadata_updated)
	dialogue_driver.sync_dialogue_block.connect(request_sync_dialogue)

	for dialogue_trigger in dialogue_triggers:
		print("Connecting trigger: " + dialogue_trigger.name, " with driver: ", dialogue_driver != null)
		dialogue_trigger.setup_dialogue_trigger(dialogue_driver, tinkerable_dialogue)
		print("PAR: ", get_parent().name, " A2 DT SIZE: ", dialogue_trigger.start_dialogue.get_connections().size())

	dialogue_window.text_processor.finished_printing_text.connect(text_finished_printing)
	unfocused_skip_line_timer.timeout.connect(skip_line_timeout)
	
	dialogue_window.dialogue_unfocused_skip_timer = unfocused_skip_line_timer

func update_buttons():
	var dialogue_options : Array[String] = []
	
	for i in range(tinkerable_dialogue.interact_prompt_buttons.size()):
		var tinker_button = tinkerable_dialogue.interact_prompt_buttons[i]

		tinker_button.on_interaction_completed.connect(select_dialogue_choice.bind(i).unbind(1))

		dialogue_options.append(tinker_button.interact_prompt)
	dialogue_window.update_choice_options(dialogue_options)

func set_visibility_state(new_state : Tinkerable.TinkerableState) -> void:
	if new_state == Tinkerable.TinkerableState.Focused:
		dialogue_window.target_dynamic_dialogue = false
		dialogue_window.set_choices_visible(true)
	else:
		dialogue_window.target_dynamic_dialogue = true
		dialogue_window.set_choices_visible(false)

#---- Connected functions ----

func main_text_updated(main_text : String) -> void:
	dialogue_window.set_text(main_text)
	#dialogue_window.recalculate_dynamic_window_size(4)

func dialogue_metadata_updated(metadata : Dictionary) -> void:
	print("Got metadata update: " + str(metadata))
	print("------------")

func calc_set_dialogue_visibility() -> void:
	if tinkerable_dialogue.other_peer_tinkering() or tinkerable_dialogue.current_focusing_tinkerer == null: #The thing after "or" is a quick fix because I haven't yet thought how it should behave (either instant swap to other peer, or other peer has to reengage)
		set_visibility_state(Tinkerable.TinkerableState.Unfocused) #or Hidden, idk, again, read comment on line 9
	else:
		set_visibility_state(tinkerable_dialogue.current_tinkerable_state)

func next_dialogue_block() -> void:
	if dialogue_window.dialogue_locked():
		dialogue_window.skip_text_printing()
	else:
		dialogue_driver.next_dialogue_block()

func select_dialogue_choice(choice_index : int) -> void:
	if dialogue_window.dialogue_locked():
		dialogue_window.skip_text_printing()
	else:
		dialogue_driver.select_dialogue_choice(choice_index)

func dialogue_state_changed(dialogue_running : bool) -> void:
	dialogue_window.set_show_dialogue(dialogue_running || tinkerable_dialogue.keep_visible) #BUMP, check choice_dialogue_trigger.gd

func tinkerer_changed(new_tinkerer : NetworkEntity) -> void:
	print("Updater tinkerer changed")
	if new_tinkerer == null:
		set_dialogue_timer_pause(false)
	else:
		set_dialogue_timer_pause(true)
	dialogue_driver.set_dialogue_parameter("has_focused_tinkerer", !(new_tinkerer == null))
	calc_set_dialogue_visibility()

func set_dialogue_timer_pause(set_paused : bool) -> void:
	unfocused_skip_line_timer.paused = set_paused

func text_finished_printing() -> void:
	start_line_skip_timer(dialogue_window.text_processor.text_letter_count * 0.02) #TODO think where better do this, idk

func start_line_skip_timer(time_to_wait : float) -> void:
	unfocused_skip_line_timer.start(time_to_wait)

func skip_line_timeout() -> void:
	if tinkerable_dialogue.network_entity != null and tinkerable_dialogue.network_entity.has_authority():
		dialogue_driver.next_dialogue_block()

#---- Syncing dialogue -----
func receive_sync_request(dialogue_sequence_name : String, dialogue_priority : int, block_index : int, responsible_parameters : Dictionary) -> void:
	sync_cached_sequence_name = dialogue_sequence_name
	dialogue_driver.sync_dialogue(dialogue_sequence_name, dialogue_priority, block_index, responsible_parameters)

func request_sync_dialogue(dialogue_sequence_name : String, block_index : int, responsible_parameters : Dictionary) -> void:
	#Most owner / net entity / other NODE dependant sync logic should be here
	#if !network_entity.has_authority():
		#return

	#Well... I'm surprised but this shit seems to work

	if dialogue_sequence_name == "":
		if responsible_parameters == {}:
			end_dialogue_rpc_simple.rpc()
		else:
			end_dialogue_rpc.rpc(responsible_parameters)

	if sync_cached_sequence_name == dialogue_sequence_name:
		if responsible_parameters == {}:
			sync_block_rpc_simple.rpc(block_index)
		else:
			sync_block_rpc_arguments.rpc(block_index, responsible_parameters)
	else:
		if responsible_parameters == {}:
			sync_seq_block_rpc_simple.rpc(dialogue_sequence_name, dialogue_driver.current_dialogue_priority, block_index)
		else:
			sync_seq_block_rpc_arguments.rpc(dialogue_sequence_name, dialogue_driver.current_dialogue_priority, block_index, responsible_parameters)
	
	sync_cached_sequence_name = dialogue_sequence_name


@rpc("reliable", "call_remote", "any_peer")
func sync_seq_block_rpc_simple(dialogue_sequence_name : String, dialogue_priority : int, dialogue_block_index : int) -> void:
	receive_sync_request(dialogue_sequence_name, dialogue_priority, dialogue_block_index, {})

@rpc("reliable", "call_remote", "any_peer")
func sync_seq_block_rpc_arguments(dialogue_sequence_name : String, dialogue_priority : int, dialogue_block_index : int, responsible_parameters : Dictionary) -> void:
	receive_sync_request(dialogue_sequence_name, dialogue_priority, dialogue_block_index, responsible_parameters)

@rpc("reliable", "call_remote", "any_peer")
func sync_block_rpc_simple(dialogue_block_index : int) -> void:
	receive_sync_request(sync_cached_sequence_name, 0, dialogue_block_index, {})

@rpc("reliable", "call_remote", "any_peer")
func sync_block_rpc_arguments(dialogue_block_index : int, responsible_parameters : Dictionary) -> void:
	receive_sync_request(sync_cached_sequence_name, 0, dialogue_block_index, responsible_parameters)

@rpc("reliable", "call_remote", "any_peer")
func end_dialogue_rpc_simple() -> void:
	dialogue_driver.sync_end_dialogue({})

@rpc("reliable", "call_remote", "any_peer")
func end_dialogue_rpc(responsible_parameters : Dictionary) -> void:
	dialogue_driver.sync_end_dialogue(responsible_parameters)

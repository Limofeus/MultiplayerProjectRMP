extends Node

@export var dialogue_triggers : Array[DialogueTrigger]
@export_group("Node References")
@export var tinkerable_dialogue : TinkerableDialogue = null
@export var dialogue_window : DialogueWindowVisual = null
@export var world_based_alter : WorldBasedControlAlter = null
var dialogue_driver : DialogueDriver = DialogueDriver.new()

func _ready():

	#TINKERABLE & CONTROL ALTER
	tinkerable_dialogue.buttons_updated.connect(update_buttons)
	#idk, maybe change this later, depending on what the view needs / capable of (Responsible for dialogue display while other peer is chatting with npc)
	tinkerable_dialogue.on_tinkerable_state_changed.connect(calc_set_dialogue_visibility.unbind(1))
	tinkerable_dialogue.tinkerer_changed.connect(calc_set_dialogue_visibility.unbind(1))
	tinkerable_dialogue.selection_changed.connect(dialogue_window.select_choise_option)
	tinkerable_dialogue.main_tinker_action_no_choice.connect(dialogue_driver.next_dialogue_block)
	world_based_alter.scale_mod_change.connect(dialogue_window.set_scale_alpha_multiplier)

	set_visibility_state(tinkerable_dialogue.current_tinkerable_state)

	dialogue_driver.on_choice_options_updated.connect(tinkerable_dialogue.update_dialogue_options)
	dialogue_driver.on_main_text_updated.connect(dialogue_window.set_text)

	dialogue_driver.on_dialogue_state_changed.connect(dialogue_window.set_show_dialogue)

	for dialogue_trigger in dialogue_triggers:
		dialogue_trigger.start_dialogue.connect(dialogue_driver.start_dialogue)

func update_buttons():
	var dialogue_options : Array[String] = []
	for i in range(tinkerable_dialogue.interact_prompt_buttons.size()):
		var tinker_button = tinkerable_dialogue.interact_prompt_buttons[i]

		tinker_button.on_interaction_completed.connect(dialogue_driver.select_dialogue_choice.bind(i))

		dialogue_options.append(tinker_button.interact_prompt)
	dialogue_window.update_choice_options(dialogue_options)

func set_visibility_state(new_state : Tinkerable.TinkerableState) -> void:
	if new_state == Tinkerable.TinkerableState.Focused:
		dialogue_window.target_dynamic_dialogue = false
		dialogue_window.set_choices_visible(true)
	else:
		dialogue_window.target_dynamic_dialogue = true
		dialogue_window.set_choices_visible(false)

func calc_set_dialogue_visibility() -> void:
	if tinkerable_dialogue.other_peer_tinkering() or tinkerable_dialogue.current_focusing_tinkerer == null: #The thing after "or" is a quick fix because I haven't yet thought how it should behave (either instant swap to other peer, or other peer has to reengage)
		set_visibility_state(Tinkerable.TinkerableState.Unfocused) #or Hidden, idk, again, read comment on line 9
	else:
		set_visibility_state(tinkerable_dialogue.current_tinkerable_state)

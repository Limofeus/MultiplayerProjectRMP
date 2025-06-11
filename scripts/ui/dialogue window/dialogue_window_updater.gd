extends Node

@export var tinkerable_dialogue : TinkerableDialogue = null
@export var dialogue_window : DialogueWindowVisual = null

func _ready():
	tinkerable_dialogue.buttons_updated.connect(update_view_buttons)

	#idk, maybe change this later, depending on what the view needs / capable of (Responsible for dialogue display while other peer is chatting with npc)
	tinkerable_dialogue.on_tinkerable_state_changed.connect(calc_set_dialogue_visibility.unbind(1))
	tinkerable_dialogue.tinkerer_changed.connect(calc_set_dialogue_visibility.unbind(1))

	tinkerable_dialogue.selection_changed.connect(dialogue_window.select_choise_option)

	set_visibility_state(tinkerable_dialogue.current_tinkerable_state)

func update_view_buttons():
	var dialogue_options : Array[String] = []
	for tinker_button in tinkerable_dialogue.interact_prompt_buttons:
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

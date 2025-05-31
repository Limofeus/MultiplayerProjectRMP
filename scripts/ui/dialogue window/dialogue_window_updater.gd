extends Node

@export var tinkerable_multibutton : TinkerableSelectMultibutton = null
@export var dialogue_window : DialogueWindowVisual = null

func _ready():
	tinkerable_multibutton.buttons_updated.connect(update_view_buttons)
	tinkerable_multibutton.on_tinkerable_state_changed.connect(set_visibility_state)
	tinkerable_multibutton.selection_changed.connect(dialogue_window.select_choise_option)

	set_visibility_state(tinkerable_multibutton.current_tinkerable_state)

func update_view_buttons():
	var dialogue_options : Array[String] = []
	for tinker_button in tinkerable_multibutton.interact_prompt_buttons:
		dialogue_options.append(tinker_button.interact_prompt)
	dialogue_window.update_choice_options(dialogue_options)

func set_visibility_state(new_state : Tinkerable.TinkerableState) -> void:
	if new_state == Tinkerable.TinkerableState.Focused:
		dialogue_window.target_dynamic_dialogue = false
		dialogue_window.set_choices_visible(true)
	else:
		dialogue_window.target_dynamic_dialogue = true
		dialogue_window.set_choices_visible(false)

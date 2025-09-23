extends TinkerableMultibutton
class_name TinkerableSelectMultibutton

@export var tinker_action_name : String = "tinker_action_0"
@export var tinker_action_increment_selection : String = "tinker_action_selection_increment"
@export var tinker_action_decrement_selection : String = "tinker_action_selection_decrement"

var current_selected_button : int = 0

signal selection_changed(new_selected_button_index : int)

func recreate_interact_prompt_buttons() -> void:
	super()
	change_selected_button(0)

func change_selected_button(new_selected_button_index : int) -> void:
	stop_all_button_interactions()
	current_selected_button = new_selected_button_index
	selection_changed.emit(current_selected_button)

func process_tinker_input(input_event : InputEvent, interacting_entity : InteractableNetworkEntity) -> void:
	if current_tinkerable_state == TinkerableState.Focused:
		if input_event.is_action_pressed(tinker_action_increment_selection):
			change_selected_button((current_selected_button + 1) % interact_prompt_buttons.size())
		elif input_event.is_action_pressed(tinker_action_decrement_selection):
			change_selected_button((current_selected_button - 1 + interact_prompt_buttons.size()) % interact_prompt_buttons.size())

		if input_event.is_action_pressed(tinker_action_name):
			interact_prompt_buttons[current_selected_button].start_interaction(interacting_entity)
		elif input_event.is_action_released(tinker_action_name) and current_tinkerable_state == TinkerableState.Focused:
				interact_prompt_buttons[current_selected_button].stop_interaction()
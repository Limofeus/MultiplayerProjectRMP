extends Node
class_name TinkerableMultibuttonView

@export var button_container : Container = null

@export var button_prompt_scene : PackedScene = null

@export var focused_window_node : Control = null
@export var unfocused_window_node : Control = null

var tinker_action_name_prefix : String = "tinker_action_"

var button_view_array : Array[TinkerableButtonView] = []

func update_buttons(button_list : Array[TinkerableMultibutton.InteractPromptButton]):
	button_view_array.clear()

	for button_prompt in button_container.get_children():
		button_container.remove_child(button_prompt)
		button_prompt.queue_free()

	for i in range(button_list.size()):
		var button : TinkerableMultibutton.InteractPromptButton = button_list[i]

		var button_instance : TinkerableButtonView = button_prompt_scene.instantiate()
		var button_key_prompt : String = InputMap.action_get_events(tinker_action_name_prefix + str(i))[0].as_text().get_slice(" ", 0)
		button_instance.set_button_params(button_key_prompt, button.interact_prompt)
		button_container.add_child(button_instance)
		button_view_array.append(button_instance)

func update_button_progress(button_index : int, progress : float) -> void:
	button_view_array[button_index].update_button_progress(progress)

func botton_interaction_completed(button_index : int) -> void:
	button_view_array[button_index].button_pressed()

func button_interact_state_changed(new_interact_state : bool, button_index : int) -> void:
	button_view_array[button_index].set_is_interacting(new_interact_state)

func tinkerable_state_changed(new_state : Tinkerable.TinkerableState) -> void:
	focused_window_node.visible = new_state == Tinkerable.TinkerableState.Focused
	unfocused_window_node.visible = new_state == Tinkerable.TinkerableState.Unfocused
	for button in button_view_array:
		button.set_spring_enabled(new_state == Tinkerable.TinkerableState.Focused)
extends Node
class_name TinkerableMultibuttonView

@export var button_container : Container = null

@export var button_prompt_scene : PackedScene = null

var tinker_action_name_prefix : String = "tinker_action_"

var button_view_array : Array[TinkerableButtonView] = []

func update_buttons(button_list : Array[TinkerableMultibutton.InteractPromptButton]):
	button_view_array.clear()

	for button_prompt in button_container.get_children():
		button_container.remove_child(button_prompt)
		button_prompt.queue_free()

	for button in button_list:
		var button_instance : TinkerableButtonView = button_prompt_scene.instantiate()
		var button_key_prompt : String = InputMap.action_get_events(tinker_action_name_prefix + str(button_view_array.size()))[0].as_text()
		button_instance.set_button_params(button_key_prompt, button.interact_prompt)
		button_container.add_child(button_instance)
		button_view_array.append(button_instance)

func update_button_progress(button_index : int, progress : float) -> void:
	button_view_array[button_index].update_button_progress(progress)
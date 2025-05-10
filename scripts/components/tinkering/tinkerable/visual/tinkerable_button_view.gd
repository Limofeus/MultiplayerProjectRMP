extends Control
class_name TinkerableButtonView

@export var key_prompt_label : Label = null
@export var action_prompt_label : Label = null
@export var button_progress_bar : ProgressBar = null

func set_button_params(key_prompt : String, action_prompt : String):
	key_prompt_label.text = key_prompt
	action_prompt_label.text = action_prompt

func update_button_progress(current_progress : float):
	button_progress_bar.value = current_progress
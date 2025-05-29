extends Control
class_name TinkerableButtonView

@export var interacting_size : float = 0.75
@export var spring_dampener_freq : float = 10.0
@export var spring_dampener_damp : float = 1.0
@export var button_pressed_velocity_bump : float = 10.0

@export var key_prompt_label : Label = null
@export var action_prompt_label : Label = null
@export var button_progress_bar : ProgressBar = null
@export var size_interaction_indicator_node : Control = null

var button_spring_dampener : SpringUtility.SpringParams = SpringUtility.SpringParams.new(1.0, 0.0)

var cur_target_size : float = 1.0
var spring_enabled : bool = false

func _process(delta):
	if spring_enabled:
		SpringUtility.UpdateSpring(button_spring_dampener, cur_target_size, delta, spring_dampener_freq, spring_dampener_damp)
		size_interaction_indicator_node.scale = Vector2.ONE * button_spring_dampener.pos

func set_button_params(key_prompt : String, action_prompt : String):
	key_prompt_label.text = key_prompt
	action_prompt_label.text = action_prompt

func update_button_progress(current_progress : float):
	button_progress_bar.value = current_progress

func button_pressed():
	button_spring_dampener.vel += button_pressed_velocity_bump

func set_is_interacting(is_interacting : bool):
	cur_target_size = interacting_size if is_interacting else 1.0

func set_spring_enabled(enabled : bool):
	size_interaction_indicator_node.scale = Vector2.ONE * cur_target_size
	spring_enabled = enabled
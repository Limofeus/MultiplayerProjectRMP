extends Tinkerable
class_name TinkerableMultibutton

class InteractButtonPromptSettings extends Resource:
	@export var interact_prompt : String = "Interact"
	@export var interact_time : float = 0.0

class InteractPromptButton:
	var interact_prompt : String = ""
	var interact_progress : float = 0.0
	var time_to_interact : float = 0.0
	var is_interacting : bool = false

	signal interact_state_changed()
	signal interaction_completed()

	func _init(_interact_prompt : String, _time_to_interact : float):
		interact_prompt = _interact_prompt
		time_to_interact = _time_to_interact
		interact_progress = 0.0

	func start_interaction() -> void:
		if is_interacting:
			return
		is_interacting = true
		interact_state_changed.emit()
		if time_to_interact == 0.0:
			interaction_completed.emit()
			stop_interaction()

	func stop_interaction() -> void:
		if !is_interacting:
			return
		interact_progress = 0.0
		is_interacting = false
		interact_state_changed.emit()

	func update_interaction_progress(delta : float) -> void:
		if is_interacting:
			interact_progress += delta
			if interact_progress >= time_to_interact:
				interaction_completed.emit()
				stop_interaction()

@export var tinker_action_name_prefix : String = "tinker_action_"
@export var interact_prompt_settings : Array[InteractButtonPromptSettings] = []
var interact_prompt_buttons : Array[InteractPromptButton] = []

signal button_state_changed(button_id : int) #Get button to find the new state if you need it :shrug: + or BETTER subscribe to button signals DIRECTLY, the array's exposed
signal button_interaction_completed(button_id : int)

func _ready():
	for i in range(interact_prompt_settings.size()):
		var interact_prompt_setting = interact_prompt_settings[i]
		var interact_prompt_button = InteractPromptButton.new(interact_prompt_setting.interact_prompt, interact_prompt_setting.interact_time)
		interact_prompt_button.interact_state_changed.connect(button_state_changed.emit.bind(i))
		interact_prompt_button.interaction_completed.connect(button_interaction_completed.emit.bind(i)) #I'm not even sure that this will work as intended so yeah, you better sub to buttons directly
		interact_prompt_buttons.append(interact_prompt_button)

#TODO: make variants fot this (Or not, look in to it later at least)
func routing_enabled() -> bool: 
	return false

func interaction_filter(interaction : Interaction) -> bool:
	if interaction is TinkerVisibilityUpdateInteraction:
		update_tinkerable_state(interaction.tinkerable_visibility_state)
	if interaction is TinkerInputEventInteraction:
		process_tinker_input(interaction.input_event)
	return interaction is TinkerInteraction

func update_tinkerable_state(new_state : TinkerableState) -> void:
	if new_state == TinkerableState.Hidden:
		stop_all_button_interactions()
	super(new_state)

func stop_all_button_interactions() -> void:
	for button in interact_prompt_buttons:
		button.stop_interaction()

func process_tinker_input(input_event : InputEvent) -> void:
	for i in range(interact_prompt_buttons.size()):
		if input_event.is_action(tinker_action_name_prefix + str(i)):
			if input_event.is_pressed():
				interact_prompt_buttons[i].start_interaction()
			else:
				interact_prompt_buttons[i].stop_interaction()
			return

#If anyone asks me who are all those comments are for, it's for me in the FUTURE!
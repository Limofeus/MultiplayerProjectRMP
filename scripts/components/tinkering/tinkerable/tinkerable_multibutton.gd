extends Tinkerable
class_name TinkerableMultibutton

class InteractPromptButton:
	var interact_prompt : String = ""
	var interact_progress : float = 0.0
	var time_to_interact : float = 0.0
	var is_interacting : bool = false

	signal on_interact_state_changed(new_state : bool)
	signal on_interaction_completed()
	signal on_progress_updated(progress : float)

	func _init(_interact_prompt : String, _time_to_interact : float):
		interact_prompt = _interact_prompt
		time_to_interact = _time_to_interact
		interact_progress = 0.0

	func start_interaction() -> void:
		if is_interacting:
			return
		is_interacting = true
		on_interact_state_changed.emit(is_interacting)
		if time_to_interact == 0.0:
			on_interaction_completed.emit()
			stop_interaction()

	func stop_interaction() -> void:
		if !is_interacting:
			return
		interact_progress = 0.0
		is_interacting = false
		on_progress_updated.emit(0.0)
		on_interact_state_changed.emit(is_interacting)

	func update_interaction_progress(delta : float) -> void:
		if is_interacting:
			interact_progress += delta
			on_progress_updated.emit(interact_progress / time_to_interact)
			if interact_progress >= time_to_interact:
				on_interaction_completed.emit()
				stop_interaction()

@export var tinker_action_name_prefix : String = "tinker_action_"
@export var interact_prompt_settings : Array[TinkerableInteractButtonPromptSettings] = []
var interact_prompt_buttons : Array[InteractPromptButton] = []

signal button_state_changed(button_id : int) #Get button to find the new state if you need it :shrug: + or BETTER subscribe to button signals DIRECTLY, the array's exposed
signal button_interaction_completed(button_id : int)
signal buttons_updated()

func _ready():
	recreate_interact_prompt_buttons()

func _process(delta):
	for button in interact_prompt_buttons:
		button.update_interaction_progress(delta)

func recreate_interact_prompt_buttons() -> void:
	stop_all_button_interactions()
	interact_prompt_buttons.clear()
	for i in range(interact_prompt_settings.size()):
		var interact_prompt_setting = interact_prompt_settings[i]
		var interact_prompt_button = InteractPromptButton.new(interact_prompt_setting.interact_prompt, interact_prompt_setting.interact_time)
		
		
		interact_prompt_button.on_interact_state_changed.connect(button_state_changed.emit.bind(i))
		interact_prompt_button.on_interaction_completed.connect(button_interaction_completed.emit.bind(i)) #I'm not even sure that this will work as intended so yeah, you better sub to buttons directly
		interact_prompt_buttons.append(interact_prompt_button)
	buttons_updated.emit()

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
		var action_name : String = tinker_action_name_prefix + str(i)
		if input_event.is_action(action_name):
			if input_event.is_action_pressed(action_name) and current_tinkerable_state == TinkerableState.Focused:
				interact_prompt_buttons[i].start_interaction()
				print("Starting interaction")
			elif input_event.is_action_released(action_name) and current_tinkerable_state == TinkerableState.Focused:
				interact_prompt_buttons[i].stop_interaction()
			return

#If anyone asks me who are all those comments are for, it's for me in the FUTURE!
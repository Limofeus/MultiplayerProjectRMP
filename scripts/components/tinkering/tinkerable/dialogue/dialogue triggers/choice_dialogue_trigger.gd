extends DialogueTrigger
class_name ChoiceDialogueTrigger

@export var choice_names : Array[String] = []
@export var sequence_names : Array[String] = []
@export var prefix_sequence_name : bool = true

var _dialogue_running : bool = false

func setup_dialogue_trigger(dialogue_driver : DialogueDriver, _tinkerable_dialogue : TinkerableDialogue = null) -> void:
	super(dialogue_driver, _tinkerable_dialogue)
	_tinkerable_dialogue.create_interact_prompt_buttons_on_ready = false
	create_and_connect_buttons(_tinkerable_dialogue)
	_tinkerable_dialogue.on_tinkerable_state_changed.connect(tinkerable_state_changed.bind(_tinkerable_dialogue))
	dialogue_driver.on_dialogue_state_changed.connect(on_dialogue_state_changed.bind(_tinkerable_dialogue))

func on_dialogue_state_changed(dialogue_running : bool, tinkerable_dialogue : TinkerableDialogue) -> void:
	_dialogue_running = dialogue_running
	if !dialogue_running:
		create_and_connect_buttons(tinkerable_dialogue)

func select_trigger_choice(choice_id : int) -> void:
	print("Trying to start dialogue...")
	start_dialogue.emit(sequence_name + sequence_names[choice_id] if prefix_sequence_name else sequence_names[choice_id], dialogue_priority) #Shared priority across all choices for now

func create_and_connect_buttons(tinkerable_dialogue : TinkerableDialogue) -> void:
	#Doing it like this so it auto unbinds whenever buttons change via dialogue
	print("Creating buttons..")
	tinkerable_dialogue.update_dialogue_options(choice_names.duplicate())
	for i in range(tinkerable_dialogue.interact_prompt_buttons.size()):
		print("Connecting button: " + str(i))
		tinkerable_dialogue.interact_prompt_buttons[i].on_interaction_completed.connect(select_trigger_choice.bind(i).unbind(1))
		print(str(tinkerable_dialogue.interact_prompt_buttons[i].on_interaction_completed.get_connections()))

#TODO: Bruh, should really move this up and decouple in to different classes (visual and tinkerable dialogue)
#PLUS need to make sure visual correctly updates each time with options and stuff and etc. rn only updates on dialogue state change
#Basically the choice options visual needs a rework lol
func tinkerable_state_changed(new_state : Tinkerable.TinkerableState, tinkerable_dialogue : TinkerableDialogue) -> void:
	tinkerable_dialogue.keep_visible = new_state == Tinkerable.TinkerableState.Focused
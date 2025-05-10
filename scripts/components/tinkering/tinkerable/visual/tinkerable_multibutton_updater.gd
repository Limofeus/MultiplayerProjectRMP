extends Node

@export var tinkerable_multibutton : TinkerableMultibutton = null
@export var tinkerable_multibutton_view : TinkerableMultibuttonView = null

func _ready():
	tinkerable_multibutton.buttons_updated.connect(update_view_buttons)
	tinkerable_multibutton.on_tinkerable_state_changed.connect(tinkerable_multibutton_view.tinkerable_state_changed)
	tinkerable_multibutton_view.tinkerable_state_changed(tinkerable_multibutton.current_tinkerable_state)

func update_view_buttons():
	tinkerable_multibutton_view.update_buttons(tinkerable_multibutton.interact_prompt_buttons)
	for i in range(tinkerable_multibutton.interact_prompt_buttons.size()):
		tinkerable_multibutton.interact_prompt_buttons[i].on_progress_updated.connect(update_button_progress.bind(i))
		tinkerable_multibutton.interact_prompt_buttons[i].on_interact_state_changed.connect(tinkerable_multibutton_view.button_interact_state_changed.bind(i))

func update_button_progress(progress : float, button_index : int) -> void: #since there's no reverse bind in godot so far, have to create helper method
	tinkerable_multibutton_view.update_button_progress(button_index, progress)
extends Node

@export var start_game_solo_button : Button
@export var options_button : Button
@export var credits_button : Button
@export var quit_game_button : Button

@export var main_game_scene : PackedScene = null
@export var options_window_scene : PackedScene = null
@export var credits_window_scene : PackedScene = null

func _ready():
	start_game_solo_button.pressed.connect(get_tree().change_scene_to_packed.bind(main_game_scene))
	options_button.pressed.connect(open_window.bind(options_window_scene))
	credits_button.pressed.connect(open_window.bind(credits_window_scene))
	quit_game_button.pressed.connect(get_tree().quit)

func open_window(window_scene : PackedScene):
	var options_window = window_scene.instantiate()
	get_parent().add_child(options_window)
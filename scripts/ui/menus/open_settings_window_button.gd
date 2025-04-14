extends Button

@export var setting_scene : PackedScene = null

func _ready():
	pressed.connect(open_settings_window)

func open_settings_window():
	var settings_instance = setting_scene.instantiate()
	get_parent().add_child(settings_instance)
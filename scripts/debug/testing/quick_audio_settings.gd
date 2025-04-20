extends Node
class_name QuickAudioSettingsSingleton

var save_path : String = "user://quick_audio_settings.kostyl"

var music_bus_id : int = 0
var sfx_bus_id : int = 0

signal on_music_volume_changed(value : float)
signal on_sfx_volume_changed(value : float)

func save_settings():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(str(get_music_volume()) + "\n" + str(get_sfx_volume()))
	file.close()

func load_settings():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var lines = file.get_as_text().split("\n")
		file.close()
		set_music_volume(float(lines[0]))
		set_sfx_volume(float(lines[1]))

func _ready():
	print("AudioSetting Singleton ready")
	music_bus_id = AudioServer.get_bus_index("Music")
	sfx_bus_id = AudioServer.get_bus_index("Sounds")
	print("Mus buf id: " + str(music_bus_id), "SFX buf id: " + str(sfx_bus_id))

	load_settings()

func set_music_volume(value : float):
	print("Set mus vol to: " + str(value))
	AudioServer.set_bus_volume_linear(music_bus_id, value)
	on_music_volume_changed.emit(value)

	save_settings()

func set_sfx_volume(value : float):
	AudioServer.set_bus_volume_linear(sfx_bus_id, value)
	on_sfx_volume_changed.emit(value)

	save_settings()

func get_music_volume() -> float:
	return AudioServer.get_bus_volume_linear(music_bus_id)

func get_sfx_volume() -> float:
	return AudioServer.get_bus_volume_linear(sfx_bus_id)
extends Node
class_name QuickAudioSettingsSingleton

var music_bus_id : int = 0
var sfx_bus_id : int = 0

signal on_music_volume_changed(value : float)
signal on_sfx_volume_changed(value : float)

func _ready():
	print("AudioSetting Singleton ready")
	music_bus_id = AudioServer.get_bus_index("Music")
	sfx_bus_id = AudioServer.get_bus_index("Sounds")
	print("Mus buf id: " + str(music_bus_id), "SFX buf id: " + str(sfx_bus_id))

func set_music_volume(value : float):
	print("Set mus vol to: " + str(value))
	AudioServer.set_bus_volume_linear(music_bus_id, value)
	on_music_volume_changed.emit(value)

func set_sfx_volume(value : float):
	AudioServer.set_bus_volume_linear(sfx_bus_id, value)
	on_sfx_volume_changed.emit(value)

func get_music_volume() -> float:
	return AudioServer.get_bus_volume_linear(music_bus_id)

func get_sfx_volume() -> float:
	return AudioServer.get_bus_volume_linear(sfx_bus_id)
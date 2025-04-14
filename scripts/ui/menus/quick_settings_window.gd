extends Node

@export var music_vol_slider : HSlider
@export var sfx_vol_slider : HSlider

func _ready():
	print("Mus volume", KQuickAudioSettings.get_music_volume())
	music_vol_slider.value = KQuickAudioSettings.get_music_volume()
	sfx_vol_slider.value = KQuickAudioSettings.get_sfx_volume()

	music_vol_slider.value_changed.connect(KQuickAudioSettings.set_music_volume)
	sfx_vol_slider.value_changed.connect(KQuickAudioSettings.set_sfx_volume)

	KQuickAudioSettings.on_music_volume_changed.connect(music_vol_slider.set_value)
	KQuickAudioSettings.on_sfx_volume_changed.connect(sfx_vol_slider.set_value)
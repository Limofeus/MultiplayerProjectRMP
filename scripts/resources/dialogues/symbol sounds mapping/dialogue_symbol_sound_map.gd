extends Resource
class_name DialogueSymbolSoundsMapping

@export var sound_symbol_dictionary : Dictionary[String, DialogueSymbolSounds] = {}
@export var fallback_dialogue_symbol_sounds : DialogueSymbolSounds = null
@export var pitch_variation : float = 0.0

func get_symbol_sound(symbol : String) -> AudioStream:
	if sound_symbol_dictionary.has(symbol):
		return sound_symbol_dictionary[symbol].get_audio_clip()
	if fallback_dialogue_symbol_sounds != null:
		return fallback_dialogue_symbol_sounds.get_audio_clip()
	return null
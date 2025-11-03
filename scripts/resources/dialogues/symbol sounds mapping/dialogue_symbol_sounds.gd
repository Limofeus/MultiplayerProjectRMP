extends Resource
class_name DialogueSymbolSounds

@export var audio_clips : Array[AudioStream] = []

func get_audio_clip() -> AudioStream:
	return audio_clips.pick_random()
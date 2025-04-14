extends AudioStreamPlayer3D

@export var base_pitch : float = 1.0
@export var pitch_randomization : float = 0.2

@export var audio_streams : Array[AudioStream] = []

func _ready():
	pitch_scale = base_pitch + randf_range(-pitch_randomization, pitch_randomization)
	stream = audio_streams[randi_range(0, audio_streams.size() - 1)]

	play()

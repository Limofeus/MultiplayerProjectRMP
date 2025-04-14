extends Node
class_name QuickDynamicMusic

@export var network_manager : NetworkManager = null

@export var ambient_stream_player : AudioStreamPlayer = null
@export var battle_stream_player : AudioStreamPlayer = null

@export var ambient_to_battle_transition_time : float = 0.5
@export var battle_to_ambient_transition_time : float = 1.0

@export var danger_add_count : int = 0
@export var is_in_battle : bool = false


var linear_transition_volume : float = 0.0

func _ready():
	network_manager.player_scenes_created.connect(start_music_players)

func start_music_players() -> void:
	ambient_stream_player.play()
	battle_stream_player.play()

func update_danger_count(danger_add : int) -> void:
	danger_add_count += danger_add
	is_in_battle = danger_add_count > 0

func _process(delta):
	var linear_transition_adjust_speed : float = 0.0

	if is_in_battle:
		linear_transition_adjust_speed = delta / ambient_to_battle_transition_time
	else:
		linear_transition_adjust_speed = -(delta / battle_to_ambient_transition_time)

	adjust_volume(linear_transition_adjust_speed)


func adjust_volume(ammount : float) -> void:
	linear_transition_volume += ammount
	linear_transition_volume = clamp(linear_transition_volume, 0.0, 1.0)

	ambient_stream_player.volume_linear = 1.0 - linear_transition_volume
	battle_stream_player.volume_linear = linear_transition_volume
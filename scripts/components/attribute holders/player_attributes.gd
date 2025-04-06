extends CreatureAttributes
class_name PlayerAttributes

var player_body : CharacterBody3D
var player_speed : float

func _ready():
	player_body = character_body
	player_speed = creature_speed
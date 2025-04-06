extends SpawnArgument
class_name PosRotSpawnArgument

@export var position : Vector3
@export var rotation : Vector3

func _init(pos : Vector3, rot : Vector3):
	position = pos
	rotation = rot
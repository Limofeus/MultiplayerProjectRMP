extends SpawnArgument
class_name ComplexParentSpawnArgument

@export var parent_path : NodePath #Path to parent node, should be Node3D

func _init(path : NodePath):
	parent_path = path
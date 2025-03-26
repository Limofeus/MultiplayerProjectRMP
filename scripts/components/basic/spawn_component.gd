extends Node
class_name SpawnComponent

func recieve_spawn_arguments(spawn_arguments : Array[SpawnArgument]) -> void:
	for spawn_argument in spawn_arguments:
		process_spawn_argument(spawn_argument)

func process_spawn_argument(spawn_argument : SpawnArgument) -> void:
	pass
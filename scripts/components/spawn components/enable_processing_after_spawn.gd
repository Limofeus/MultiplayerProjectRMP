extends SpawnComponent

const PROCESS_SET_CHANNEL = 0

@export var nodes_to_process : Array[Node]
@export var enable_before_physics_frame : bool = true

signal nodes_enabled()

func _ready():
	set_nodes_process_mode(Node.PROCESS_MODE_DISABLED)

func recieve_spawn_arguments(spawn_arguments : Array[SpawnArgument]) -> void:
	enable_processing.rpc()

@rpc("reliable", "call_local", "any_peer", PROCESS_SET_CHANNEL)
func enable_processing() -> void:
	if enable_before_physics_frame:
		var callable = set_nodes_process_mode.bind(Node.PROCESS_MODE_INHERIT)
		get_tree().physics_frame.connect(callable, CONNECT_ONE_SHOT)
	else:
		set_nodes_process_mode(Node.PROCESS_MODE_INHERIT)
	nodes_enabled.emit()

func set_nodes_process_mode(process_mode_to_set) -> void:
	for node in nodes_to_process:
		node.process_mode = process_mode_to_set

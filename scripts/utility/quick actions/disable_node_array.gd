extends Node

@export var node_array : Array[Node] = []

@export var hide_nodes : Array[Node3D] = []

func disable_nodes() -> void:
	disable_node_array(node_array)
	for nodeh in hide_nodes:
		nodeh.visible = false

func disable_node_array(node_array : Array[Node]) -> void:
	StaticUtility.set_node_array_process_mode(node_array, Node.PROCESS_MODE_DISABLED)
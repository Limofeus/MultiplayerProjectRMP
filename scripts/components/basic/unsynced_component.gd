extends  EntityComponent
class_name UnsyncedComponent

#component used to find a node that should not be synced with other peers

@export var unsynced_node_path : String

var unsynced_node : Node

func find_unsynced_node() -> void:
	unsynced_node = get_node(unsynced_node_path)
	if unsynced_node == null:
		print("Unsynced node not found at path: " + unsynced_node_path)

func _ready() -> void:
	find_unsynced_node()
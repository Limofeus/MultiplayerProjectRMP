extends EntityComponent
class_name DestructionComponent

#TODO: Code's similar to owner change, should be refactored, also add force destroy / owner change to the base refactored code
#This might help: https://github.com/godotengine/godot/issues/42111

@export var nodes_to_disable : Array[Node] = [] #Disable before destruction to avoid Node not found errors on other peers? hopefully...
#Well, that did not help, i'll go change network spawner then, think it's a problem with naming scheme for net entities

signal on_destruction()

func destroy_entity(propagate : bool = true):
	if(propagate):
		propagate_destruction.rpc()
	StaticUtility.set_node_array_process_mode(nodes_to_disable, Node.PROCESS_MODE_DISABLED)

	on_destruction.emit()

	network_entity.queue_free()

@rpc("reliable", "call_remote", "any_peer")
func propagate_destruction():
	destroy_entity(false)

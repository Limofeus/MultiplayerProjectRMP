extends DestructionComponent
class_name SequentialDestructionComponent


@export var sequential_deletion_nodes : Array[Node] = [] #Since godots exported arrays do not support nesting and resources cannot contain node refs will do it like the line below describes it...
#Null = wait for time in wait times
@export var sequential_deletion_wait_times : Array[float] = []

func destroy_entity(propagate : bool = true):
	if(propagate):
		propagate_destruction.rpc()
	StaticUtility.set_node_array_process_mode(nodes_to_disable, Node.PROCESS_MODE_DISABLED)

	on_destruction.emit()
	destruction_coroutine()


func destruction_coroutine():
	var wait_index_counter = 0

	for node in sequential_deletion_nodes:
		if(node == null):
			await get_tree().create_timer(sequential_deletion_wait_times[wait_index_counter]).timeout
			wait_index_counter += 1
		else:
			node.queue_free()

	network_entity.queue_free()

@rpc("reliable", "call_remote", "any_peer")
func propagate_destruction():
	destroy_entity(false)

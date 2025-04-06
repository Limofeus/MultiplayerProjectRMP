extends EntityComponent
class_name CanMountComponent

@export var disable_when_mounted : Array[Node]
@export var hide_when_mounted : Array[Node]
@export var node_to_set_position_on_dismount : Node3D

func try_mount(entity_to_mount : NetworkEntity) -> void:
	if entity_to_mount == null:
		return

	var mountable_component = StaticNetworkUtility.find_shared_component_on_entity(entity_to_mount, MountableComponent)

	if mountable_component != null:
		network_entity.start_interaction(entity_to_mount, GenericActionInteraction.new("mount"))
		print("Mouinting sent")

func confirm_mount() -> void:
		print("Confirmed " + str(network_entity.get_current_authority()) + " entity mount on peer" + str(multiplayer.get_unique_id()))
		StaticUtility.set_node_array_process_mode(disable_when_mounted, Node.PROCESS_MODE_DISABLED)
		for node in hide_when_mounted: #TODO: prbbly add a static utility function for this
			node.hide()

func dismount(position_on_dismount : Vector3) -> void:
		print("Confirmed dismount")
		node_to_set_position_on_dismount.global_position = position_on_dismount
		StaticUtility.set_node_array_process_mode(disable_when_mounted, Node.PROCESS_MODE_INHERIT)
		for node in hide_when_mounted:
			node.show()
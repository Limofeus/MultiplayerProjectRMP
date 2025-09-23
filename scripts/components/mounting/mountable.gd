extends InteractionReceivingComponent
class_name MountableComponent

@export var owner_changer : OwnerChangeComponent
@export var enable_when_mounted : Array[Node]
@export var dismount_position : Node3D

var current_mounter : InteractableNetworkEntity = null

func _ready():
	StaticUtility.set_node_array_process_mode(enable_when_mounted, Node.PROCESS_MODE_DISABLED)

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if interaction is GenericActionInteraction and interaction.action_string == "mount":
		print("Mounting recieved")
		try_mount.rpc_id(network_entity.get_current_authority(), interacted_entity.get_path())

func dismount() -> void:
	propagate_entity_dismounting.rpc()

@rpc("reliable", "call_local", "any_peer")
func try_mount(mounter_entity_path :  NodePath):
	if current_mounter != null:
		return
	var mounter_authority = get_node(mounter_entity_path).get_current_authority()
	if mounter_authority != network_entity.get_current_authority():
		owner_changer.set_new_owner(mounter_authority, true) #Force change owner because we can be sure that this rpc is processed on current owner
	propagate_entity_mounting.rpc(mounter_entity_path)

@rpc("reliable", "call_local", "any_peer")
func propagate_entity_mounting(mounter_entity_path :  NodePath):
	current_mounter = get_node(mounter_entity_path)
	StaticUtility.set_node_array_process_mode(enable_when_mounted, Node.PROCESS_MODE_INHERIT)
	StaticNetworkUtility.find_owner_component_on_entity(current_mounter, CanMountComponent).confirm_mount()

@rpc("reliable", "call_local", "authority")
func propagate_entity_dismounting() -> void:
	StaticUtility.set_node_array_process_mode(enable_when_mounted, Node.PROCESS_MODE_DISABLED)
	StaticNetworkUtility.find_owner_component_on_entity(current_mounter, CanMountComponent).dismount(dismount_position.global_position)
	current_mounter = null

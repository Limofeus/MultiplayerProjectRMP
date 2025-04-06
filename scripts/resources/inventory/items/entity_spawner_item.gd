extends ToolItem
class_name EntitySpawnerItem

enum SPAWN_FROM_POSITION {ITEM_USE_NODE , HEAD_NODE , HAND_NODE }

@export var scene_to_instantiate : PackedScene
@export var spawn_from_position : SPAWN_FROM_POSITION = SPAWN_FROM_POSITION.ITEM_USE_NODE
@export var copy_rotation : bool = true
@export var position_offset : float = 0.3

func _use_tool(item_user : SpatialItemUser) -> void:
	var item_use_node : Node3D = pick_spawn_node(item_user)
	spawn_network_entity(item_user, item_use_node)

func pick_spawn_node(item_user : SpatialItemUser) -> Node3D:
	var item_use_node : Node3D = null
	if spawn_from_position == SPAWN_FROM_POSITION.ITEM_USE_NODE:
		item_use_node = item_user.item_use_node
	elif spawn_from_position == SPAWN_FROM_POSITION.HEAD_NODE:
		item_use_node = item_user.head_node
	elif spawn_from_position == SPAWN_FROM_POSITION.HAND_NODE:
		item_use_node = item_user.hand_node
	return item_use_node

func spawn_network_entity(_item_user : SpatialItemUser, item_use_node : Node3D) -> void:
	StaticNetworkUtility.spatial_spawn_network_entity(scene_to_instantiate, item_use_node.global_position + (-item_use_node.global_basis.z * position_offset), item_use_node.global_rotation if copy_rotation else Vector3.ZERO)
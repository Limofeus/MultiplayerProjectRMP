extends EntityComponent
class_name CreatureItemUserComponent

@export var creature_team_id : int = 0
@export var creature_inventory : CreatureInventoryComponent = null

@export var spatial_node : Node3D = null
@export var character_body : CharacterBody3D = null
@export var head_node : Node3D = null
var creature_item_user : CreatureItemUser = null

func _ready():
	creature_item_user = CreatureItemUser.new(spatial_node, character_body, head_node, creature_team_id)
	if creature_inventory != null:
		creature_inventory.creature_item_user = creature_item_user

func _process(delta):
	creature_item_user.item_use_cooldown = max(creature_item_user.item_use_cooldown - delta, 0.0)

func use_selected_item():
	creature_inventory.use_selected_item(creature_item_user)
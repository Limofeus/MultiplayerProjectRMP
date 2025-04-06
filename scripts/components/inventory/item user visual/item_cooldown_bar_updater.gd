extends UnsyncedComponent

@export var item_user_component : CreatureItemUserComponent = null 
var item_user : ItemUser = null

func _ready():
	super()
	item_user = item_user_component.creature_item_user

func _process(delta):
	unsynced_node.value = item_user.item_use_cooldown
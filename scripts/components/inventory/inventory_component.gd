extends EntityComponent
class_name InventoryComponent

#This class is not used rn, rework or delete?

@export var inventory_size : int = 1

var item_container : ItemContainer = null

func _ready():
	item_container = ItemContainer.new(inventory_size)
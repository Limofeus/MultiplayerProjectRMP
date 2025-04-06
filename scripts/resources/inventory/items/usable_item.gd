extends InventoryItem
class_name UsableItem

@export var use_string : String = "Use" #Consume, etc.

func use_item(item_user : ItemUser) -> void:
	pass
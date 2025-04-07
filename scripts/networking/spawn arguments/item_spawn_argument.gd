extends SpawnArgument
class_name ItemSpawnArgument

var item : InventoryItem = null
var ammount : int = 1

func _init(set_item : InventoryItem, set_ammount : int = 1):
	item = set_item
	ammount = set_ammount
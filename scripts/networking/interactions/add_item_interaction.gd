extends Interaction
class_name AddItemInteraction

var item : InventoryItem = null
var amount : int = 1

func _init(item : InventoryItem, amount : int = 1) -> void:
	self.item = item
	self.amount = amount
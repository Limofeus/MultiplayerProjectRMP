extends Node
class_name ItemSlot

@export var item_icon_node : TextureRect = null
@export var amount_label_node : Label = null

func update_slot(item : InventoryItem, amount : int = 1) -> void:
	if item_icon_node != null and item != null:
		item_icon_node.texture = item.icon
	if amount_label_node != null:
		amount_label_node.text = str(amount)
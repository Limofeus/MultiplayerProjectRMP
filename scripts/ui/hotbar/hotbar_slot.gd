extends ItemSlot
class_name HotbarSlot

@export var slot_num_label : Label = null
@export var selection_indicator : Control = null

func update_slot(item : InventoryItem, amount : int = 1, slot_number : int = 0, selected : bool = false) -> void:
	super.update_slot(item, amount)
	slot_num_label.text = str(slot_number)
	selection_indicator.visible = selected #Replace with animation for oMaM, leave shitty for this project

func select_slot() -> void:
	pass

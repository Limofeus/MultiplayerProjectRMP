extends Resource
class_name ItemContainer

@export var storage_capacity : int = 1
@export var items : Array[InventoryItem] = []
@export var item_count : Array[int] = []

signal on_container_updated()

func _init(new_storage_capacity : int = 1) -> void:
	storage_capacity = new_storage_capacity

	for i in range(storage_capacity): #TODO: Add resizing function
		items.append(null)
		item_count.append(0)

	on_container_updated.emit()

func is_full() -> bool:
	for i in range(storage_capacity):
		if items[i] == null:
			return false
	return true

#No items per slot limit
func has_room_for(item : InventoryItem) -> int: #Returns the first slot suitable for the item
	for i in range(storage_capacity):
		if items[i] == null:
			return i
		elif items[i] == item:
			return i
	return -1

func add_item(item : InventoryItem, amount : int = 1, slot : int = -1) -> void:
	if slot != -1 and slot < storage_capacity and (items[slot] == null or items[slot] == item):
		items[slot] = item
		item_count[slot] = amount
	else:
		for i in range(storage_capacity):
			if items[i] == null:
				items[i] = item
				item_count[i] = amount
				break
			elif items[i] == item:
				item_count[i] += amount
				break

	on_container_updated.emit() #TODO: Maybe add separate item added/removed signals (Also not update when not needed?)

func remove_item_at(slot : int, amount : int = 1) -> void:
	item_count[slot] -= amount
	if item_count[slot] <= 0:
		items[slot] = null

	on_container_updated.emit()

func remove_item(item : InventoryItem, amount : int = 1, slot : int = -1) -> void:
	if slot != -1 and slot < storage_capacity and items[slot] == item:
		item_count[slot] -= amount
		if item_count[slot] <= 0:
			items[slot] = null

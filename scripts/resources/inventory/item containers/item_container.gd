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

#Does not check stacks, dunno where would you want to use this :shrug:
func is_full() -> bool:
	for i in range(storage_capacity):
		if items[i] == null:
			return false
	return true

func has_room_for(item : InventoryItem) -> bool:
	return find_suitable_slot(item) >= 0

func find_suitable_slot(item : InventoryItem) -> int: #Returns the first slot suitable for the item
	for i in range(storage_capacity):
		if items[i] == null:
			return i
		elif items[i] == item and item_count[i] < item.max_stack_size:
			return i
	return -1

func max_free_space_for_item(item : InventoryItem) -> int:
	var free_space = 0
	for i in range(storage_capacity):
		if items[i] == null:
			free_space += item.max_stack_size
		elif items[i] == item:
			free_space += item.max_stack_size - item_count[i]
	return free_space

func add_item(item : InventoryItem, amount : int = 1, slot : int = -1) -> void:
	if slot != -1 and slot < storage_capacity:
		#Slot set manually
		if items[slot] == null or items[slot] == item:
			items[slot] = item
			item_count[slot] = min(amount, item.max_stack_size)
			#TODO: Will probably be very rarely used but handle ammounts greater than max stack size (rn items will be removed)
	else:
		#Auto find slot
		if amount > max_free_space_for_item(item):
			print("Some items removed since inventory is full!")

		#Not sure, but this should work 👼
		for i in range(storage_capacity):
			if items[i] == null:
				items[i] = item
				item_count[i] = min(amount, item.max_stack_size)
				amount -= item_count[i]
			elif items[i] == item and item_count[i] < item.max_stack_size:
				item_count[i] += amount
				amount -= item_count[i]
			if amount <= 0:
				break

	on_container_updated.emit() #TODO: Maybe add separate item added/removed signals (Also not update when not needed?)

#Doesnt account for amount greater than max stack size
func remove_item_at(slot : int, amount : int = 1) -> void:
	item_count[slot] -= amount
	if item_count[slot] <= 0:
		items[slot] = null

	on_container_updated.emit()

func clear_slot(slot : int) -> void:
	items[slot] = null
	item_count[slot] = 0

	on_container_updated.emit()

func remove_item(item : InventoryItem, amount : int = 1, slot : int = -1) -> void:
	if slot != -1 and slot < storage_capacity and items[slot] == item:
		item_count[slot] -= amount
		if item_count[slot] <= 0:
			items[slot] = null

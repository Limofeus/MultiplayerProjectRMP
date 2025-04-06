extends Node
class_name Hotbar

@export var slot_container : Control = null
@export var hotbar_selector : Control = null
@export var label_item_name : Label = null

#@export var selected_slot : int = 0 #Is inside SelectionItemContainer

@export var default_selector_pos : float = 153.3
@export var per_slot_pos_increment : float = 230.0

@export var hotbar_slot_scene : PackedScene = null

var _item_container : ItemContainer = null #Player character should set this thing
var slots : Array[Node] = []

func connect_item_container(item_container : ItemContainer):
	_item_container = item_container
	_item_container.on_container_updated.connect(update_slots)
	update_slots()

func update_slots():
	for slot in slots:
		slot.queue_free()
	slots.clear()
	for i in range(_item_container.storage_capacity):
		var new_slot : HotbarSlot = hotbar_slot_scene.instantiate()
		slot_container.add_child(new_slot)
		slots.append(new_slot)
		if new_slot is HotbarSlot:
			new_slot.update_slot(_item_container.items[i], _item_container.item_count[i], i + 1, _item_container is SelectionItemContainer and i == _item_container.selected_slot)

	hotbar_selector.position.x = default_selector_pos + (per_slot_pos_increment * _item_container.selected_slot)
	if _item_container.items[_item_container.selected_slot] != null:
		label_item_name.text = _item_container.items[_item_container.selected_slot].name
	else:
		label_item_name.text = ""

func _process(delta):
	pass

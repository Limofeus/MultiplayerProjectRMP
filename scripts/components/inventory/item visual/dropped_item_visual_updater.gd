extends Node
class_name DroppedItemVisualUpdater

@export var dropped_item_component : DroppedItemComponent = null
@export var dropped_item_visual : DroppedItemVisual = null
@export var destruction_component : DestructionComponent = null

func _ready():
	dropped_item_component.item_set.connect(dropped_item_visual.update_visual)
	destruction_component.on_destruction.connect(dropped_item_visual.on_item_pickup)

	dropped_item_component.item_picked_up.connect(update_item_labels)

func update_item_labels():
	dropped_item_visual.update_visual(dropped_item_component.inventory_item_resource, dropped_item_component.item_ammount)

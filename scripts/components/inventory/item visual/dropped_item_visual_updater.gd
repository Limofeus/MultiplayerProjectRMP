extends Node
class_name DroppedItemVisualUpdater

@export var dropped_item_component : DroppedItemComponent = null
@export var dropped_item_visual : DroppedItemVisual = null
@export var destruction_component : DestructionComponent = null

func _ready():
	dropped_item_component.item_set.connect(dropped_item_visual.update_visual)
	destruction_component.on_destruction.connect(dropped_item_visual.on_item_pickup)
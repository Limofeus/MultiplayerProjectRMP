extends Node
class_name DroppedItemVisualUpdater

@export var dropped_item_component : DroppedItemComponent = null
@export var dropped_item_visual : DroppedItemVisual = null

func _ready():
	dropped_item_component.item_set.connect(dropped_item_visual.update_visual)
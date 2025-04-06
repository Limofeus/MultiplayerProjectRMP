extends Resource
class_name InventoryItem

@export var name : String = "Item name"
@export var description : String = "Item description"
@export var stackable : bool = false #Item container does not implement unstackable items yet
@export var icon : Texture2D = preload("res://sprites/testing/test_texture.png")
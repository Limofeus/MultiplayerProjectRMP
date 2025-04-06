extends InventoryItem
class_name SelectableItem

@export var select_string : String = "Select" #Equip, Wear, etc.

func _item_selected(item_container : SelectionItemContainer, item_user : ItemUser = null) -> void: 
	#item user will not be always present during item selection, but only if it's owner who's selecting an item... kind of a bad system I know, but... idk, deal with it I guess....
	#Forget this, I'll trace this later this thing gets called on all peers I think and also has item user arg on all peers, blah blah
	#TODO: ~~Kill myself~~ come up with a better TODO notice
	pass

func _item_deselected(item_container : SelectionItemContainer, item_user : ItemUser = null) -> void:
	pass
extends Node

@export var player_inventory : PlayerInventoryComponent = null

@export var debug_items : Array[InventoryItem] = []
var selected_deb_item : int = 0

func _process(delta):
	ImGui.Begin("InvItemAddTest")
	if ImGui.Button("Cycle"):
		selected_deb_item = (selected_deb_item + 1) % debug_items.size()
	if ImGui.Button("Add " + debug_items[selected_deb_item].name):
		player_inventory.add_item(debug_items[selected_deb_item])
	ImGui.End()

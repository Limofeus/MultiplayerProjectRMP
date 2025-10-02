@tool
extends Line2D

@export_tool_button("Save") var save_button : Callable = save_symbol

@export var symbol_name : String = " "
@export var file_prefix : String = "star_map_symbol_"
@export var resolution_divider : float = 128.0
@export var resource_save_path : String = "res://temp/personolised stars testing/starmaps resources/"

func save_symbol():
	var star_map : SymbolStarMap = SymbolStarMap.new()
	star_map.symbol_name = symbol_name
	for point in points:
		star_map.point_array.append(point / resolution_divider)
	ResourceSaver.save(star_map, resource_save_path + file_prefix + str(symbol_name.unicode_at(0)) + ".res")
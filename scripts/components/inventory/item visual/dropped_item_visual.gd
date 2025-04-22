extends Node3D
class_name DroppedItemVisual

@export var item_display_plane : MeshInstance3D = null
@export var tool_item_model_holder : Node3D = null
@export var item_light : OmniLight3D = null

@export var max_light_power : float = 0.8

@export var spring_damping : float = 0.6
@export var spring_freq : float = 10.0

var item_scaler_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)
var eq_pos : float = 1.0

func _ready():
	scale = Vector3.ZERO
	item_light.light_energy = 0.0

func _process(delta):
	scale = Vector3.ONE * max(item_scaler_spring.pos, 0.0)
	item_light.light_energy = max(item_scaler_spring.pos * max_light_power, 0.0)
	SpringUtility.UpdateSpring(item_scaler_spring, eq_pos, delta, spring_freq, spring_damping)

func update_visual(item : InventoryItem, ammount : int) -> void:
	if item is ToolItem:
		tool_item_model_holder.visible = true
		item_display_plane.visible = false

		for child in tool_item_model_holder.get_children():
			child.queue_free()
		
		var tool_item_scene : PackedScene = item.tool_scene
		var tool_item_instance : Node3D = tool_item_scene.instantiate()
		tool_item_model_holder.add_child(tool_item_instance)

	else:
		tool_item_model_holder.visible = false
		item_display_plane.visible = true
		var item_material : StandardMaterial3D = item_display_plane.material_override
		item_material.albedo_texture = item.icon

func on_item_pickup() -> void:
	eq_pos = 0.0

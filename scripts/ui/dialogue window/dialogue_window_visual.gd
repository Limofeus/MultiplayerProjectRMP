extends Node
class_name DialogueWindowVisual

const MAX_ITERS : int = 30

@export var spring_freq = 15.0
@export var spring_damp = 1.0

@export var modulate_item : CanvasItem = null
@export var interpolating_content : Control = null

@export var dynamic_dialogue_box_container : Container = null
@export var dynamic_dialogue_box_content : Control = null #resized based on dynamic text size
@export var dynamic_dialogue_text_label : RichTextLabel = null

@export var static_dialogue_box_container : Container = null
@export var static_dialogue_box_content : Control = null
@export var static_dialogue_text_label : RichTextLabel = null #opposite of dynamic, text size based on content size

var spring_dampener : SpringUtility.SpringParams = SpringUtility.SpringParams.new(1.0) #1 - dynamic, 0 - static

var target_dynamic_dialogue : bool = true:
	set(value):
		if value:
			update_dynamic_dialogue_box()
		else:
			update_static_dialogue_box()
		target_dynamic_dialogue = value

var cur_visible_dynamic_dialogue : bool = true

#@export_tool_button("TestResize")
var button = recalculate_dynamic_window_size.bind(4)

func _ready():
	update_static_dialogue_box()
	update_dynamic_dialogue_box()

func _process(delta):
	SpringUtility.UpdateSpring(spring_dampener, 1.0 if target_dynamic_dialogue else 0.0, delta, spring_freq, spring_damp)
	var lerp_pos = spring_dampener.pos
	
	interpolating_content.position = lerp(static_dialogue_box_container.position, dynamic_dialogue_box_container.position, spring_dampener.pos)
	interpolating_content.size = lerp(static_dialogue_box_container.size, dynamic_dialogue_box_container.size, spring_dampener.pos)

	reposition_dynamic_dialogue()
	reposition_static_dialogue()
	
	change_canvas_transparency(lerp_pos, dynamic_dialogue_text_label)
	change_canvas_transparency(1.0 - lerp_pos, static_dialogue_text_label)

func update_dynamic_dialogue_box():
	#dynamic_dialogue_text_label.show()
	#static_dialogue_text_label.hide()

	#Not updating size cus label size drives content size for dynamic dialogue box
	dynamic_dialogue_text_label.pivot_offset = dynamic_dialogue_text_label.size / 2.0

func reposition_dynamic_dialogue():
	reposition_to_control_center(dynamic_dialogue_text_label, interpolating_content)
	dynamic_dialogue_text_label.scale = Vector2.ONE * (interpolating_content.size.y / dynamic_dialogue_box_container.size.y)

func update_static_dialogue_box():
	#dynamic_dialogue_text_label.hide()
	#static_dialogue_text_label.show()
	
	static_dialogue_text_label.size = static_dialogue_box_content.size
	static_dialogue_text_label.pivot_offset = static_dialogue_text_label.size / 2.0

func reposition_static_dialogue():
	reposition_to_control_center(static_dialogue_text_label, interpolating_content)
	static_dialogue_text_label.scale = Vector2.ONE * (interpolating_content.size.x / static_dialogue_box_container.size.x)

func reposition_to_control_center(reposition_node : Control, target_node : Control):
	var target_center_position : Vector2 = target_node.position + (target_node.size / 2.0)
	reposition_node.position = target_center_position - (reposition_node.size / 2.0)

func change_canvas_transparency(target_alpha : float, canvas_item : CanvasItem):
	canvas_item.self_modulate.a = target_alpha

func recalculate_dynamic_window_size(target_line_count : int, start_max_size : float = 3000.0):
	var min_size : float = 0.0
	var max_size : float = start_max_size
	var last_comfortable_size : float = 0.0
	for i in range(MAX_ITERS):
		var check_size : float = (min_size + max_size) / 2.0
		if check_step_size(check_size, target_line_count):
			min_size = check_size
		else:
			last_comfortable_size = check_size + 1.0
			max_size = check_size

	dynamic_dialogue_text_label.size.x = last_comfortable_size
	dynamic_dialogue_text_label.size.y = dynamic_dialogue_text_label.get_content_height()

	dynamic_dialogue_box_content.custom_minimum_size = dynamic_dialogue_text_label.size
	dynamic_dialogue_box_container.size = Vector2.ZERO

func check_step_size(cur_size : float, target_line_count : int) -> bool:
	dynamic_dialogue_text_label.size.x = cur_size
	return dynamic_dialogue_text_label.get_line_count() > target_line_count
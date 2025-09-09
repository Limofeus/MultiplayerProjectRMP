extends Node
class_name DialogueWindowVisual

const MAX_ITERS : int = 30

@export_group("Cross-fade spring")
@export var spring_freq = 15.0
@export var spring_damp = 1.0

@export_group("State spring")
@export var state_spring_freq = 12.0
@export var state_spring_damp = 1.0
@export var static_min_scale = 0.8

@export_group("Dialogue options")
@export var dialogue_option_scene : PackedScene = null
@export var dialogue_option_container : Container = null

@export_group("Misc")
@export var modulate_item : CanvasItem = null
@export var interpolating_content : Control = null
@export var interpolating_content_lerp_power : float = 10.0
@export var scale_copy_node : Control = null
@export var unfocused_skip_progress_bar : ProgressBar = null

@export var post_print_lock_time : float = 0.35

@export_group("Dynamic dialogue box")
@export var dynamic_dialogue_box_container : Container = null
@export var dynamic_dialogue_box_content : Control = null #resized based on dynamic text size
@export var dynamic_dialogue_text_label : RichTextLabel = null

@export_group("Static dialogue box")
@export var static_dialogue_box_container : Container = null
@export var static_dialogue_box_content : Control = null
@export var static_dialogue_text_label : RichTextLabel = null #opposite of dynamic, text size based on content size

var text_processor : DialogueTextProcessor = DialogueTextProcessor.new()
var dialogue_metadata : Dictionary = {} #Chain updated through dialogue driver

var spring_dampener : SpringUtility.SpringParams = SpringUtility.SpringParams.new(1.0) #1 - dynamic, 0 - static

var dialogue_state_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0)
var dialogue_state_target : float = 0.0
var dialogue_unfocused_skip_timer : Timer = null

var target_dynamic_dialogue : bool = true:
	set(value):
		if value:
			update_dynamic_dialogue_box()
		else:
			update_static_dialogue_box()
		target_dynamic_dialogue = value

var cur_visible_dynamic_dialogue : bool = true

var scale_multiplier : float = 1.0
var alpha_multiplier : float = 1.0

var smoothed_dynamic_container_size : Vector2 = Vector2.ZERO

#@export_tool_button("TestResize")
#var button = recalculate_dynamic_window_size.bind(4)

func _ready():
	process_priority = 1 #NOTICE: check world based control alter
	update_static_dialogue_box()
	update_dynamic_dialogue_box()
	text_processor.text_labels = [static_dialogue_text_label, dynamic_dialogue_text_label]

func _process(delta):
	interpolate_dialogue_box(delta)

	text_processor.text_process_step(delta)
	unfocused_skip_progress_bar.value = 1.0 - (dialogue_unfocused_skip_timer.time_left / dialogue_unfocused_skip_timer.wait_time) if text_processor.done_printing else 0.0

#Dialogue box

func interpolate_dialogue_box(delta):
	SpringUtility.UpdateSpring(spring_dampener, 1.0 if target_dynamic_dialogue else 0.0, delta, spring_freq, spring_damp)
	SpringUtility.UpdateSpring(dialogue_state_spring, dialogue_state_target, delta, state_spring_freq, state_spring_damp)
	
	var lerp_pos = spring_dampener.pos
	
	smoothed_dynamic_container_size = StaticUtility.lerp_dampen(smoothed_dynamic_container_size, dynamic_dialogue_box_container.size, interpolating_content_lerp_power, delta)
	var dynamic_interpolating_content_position = dynamic_dialogue_box_container.global_position + (dynamic_dialogue_box_container.size / 2.0) - (smoothed_dynamic_container_size / 2.0)

	interpolating_content.size = lerp(static_dialogue_box_container.size, smoothed_dynamic_container_size, spring_dampener.pos)
	interpolating_content.global_position = lerp(static_dialogue_box_container.global_position + (( Vector2.ONE - interpolating_content.scale) * interpolating_content.size / 2.0), dynamic_interpolating_content_position, spring_dampener.pos)

	reposition_dynamic_dialogue()
	reposition_static_dialogue()
	
	change_canvas_transparency(lerp_pos, dynamic_dialogue_text_label)
	change_canvas_transparency(1.0 - lerp_pos, static_dialogue_text_label)

	modulate_item.modulate.a = alpha_multiplier * dialogue_state_spring.pos
	scale_copy_node.scale = Vector2.ONE * (scale_multiplier * dialogue_state_spring.pos)

	center_pivot(interpolating_content)
	center_pivot(dynamic_dialogue_text_label)
	#copy_scale(scale_copy_node, interpolating_content)
	var interpolating_content_scale_factor : float = scale_multiplier  * dialogue_state_spring.pos
	interpolating_content.scale = Vector2.ONE * (lerp(interpolating_content_scale_factor, static_min_scale + (interpolating_content_scale_factor * (1.0 - static_min_scale)), 1.0 - lerp_pos))
	copy_scale(scale_copy_node, dynamic_dialogue_text_label)

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

func center_pivot(target_node : Control):
	target_node.pivot_offset = target_node.size / 2.0

func copy_scale(copy_from : Control, copy_to : Control):
	copy_to.scale = copy_from.scale

func change_canvas_transparency(target_alpha : float, canvas_item : CanvasItem):
	canvas_item.self_modulate.a = target_alpha

func recalculate_dynamic_window_size(target_line_count : int, start_max_size : float = 3000.0):
	var min_size : float = 0.0
	var max_size : float = start_max_size
	var last_comfortable_size : float = 0.0

	dynamic_dialogue_text_label.size.x = 400.0 #TODO: Replace with dynamic value
	var deb_tl_count : int = dynamic_dialogue_text_label.get_line_count()
	#print("DEB_TL_COUNT: " + str(deb_tl_count))

	for i in range(MAX_ITERS):
		var check_size : float = (min_size + max_size) / 2.0
		if check_step_size_line(check_size, deb_tl_count):
		#if check_step_size_aspect(check_size, 6):
			min_size = check_size
		else:
			last_comfortable_size = check_size + 1.0
			max_size = check_size

	dynamic_dialogue_text_label.size.x = last_comfortable_size
	dynamic_dialogue_text_label.size.x = dynamic_dialogue_text_label.get_content_width()
	dynamic_dialogue_text_label.size.y = dynamic_dialogue_text_label.get_content_height()

	dynamic_dialogue_box_content.custom_minimum_size = dynamic_dialogue_text_label.size
	
	dynamic_dialogue_box_container.size = Vector2.ZERO
	dynamic_dialogue_box_container.position = dynamic_dialogue_box_container.size / -2.0 #NOTE: Долбаёб писал это + посмотри на верх, там TODO

func check_step_size_line(cur_size : float, target_line_count : int) -> bool:
	dynamic_dialogue_text_label.size.x = cur_size
	return dynamic_dialogue_text_label.get_line_count() > target_line_count

func check_step_size_aspect(cur_size : float, target_aspect : float) -> bool:
	dynamic_dialogue_text_label.size.x = cur_size
	dynamic_dialogue_text_label.size.y = dynamic_dialogue_text_label.get_content_height()
	return dynamic_dialogue_text_label.size.aspect() <= target_aspect

#Choices

func set_choices_visible(set_visible : bool):
	dialogue_option_container.visible = set_visible

func update_choice_options(choice_options : Array[String]):
	for child in dialogue_option_container.get_children():
		child.queue_free()

	for option in choice_options:
		var new_choice_option_visual : DialogueChoiceOptionVisual = dialogue_option_scene.instantiate()
		dialogue_option_container.add_child(new_choice_option_visual)
		new_choice_option_visual.set_text(option)

func select_choise_option(index : int):
	for child in dialogue_option_container.get_children():
		var choise_option_visual = child as DialogueChoiceOptionVisual
		choise_option_visual.set_selected(choise_option_visual.get_index() == index)

#Text processing

func text_completion_delay_lock() -> bool:
	return text_processor.time_since_done_printing <= post_print_lock_time

func printing_in_progress() -> bool:
	return !text_processor.done_printing

#Other ext

func dialogue_locked() -> bool:
	return (printing_in_progress() or text_completion_delay_lock())

func skip_text_printing():
	text_processor.skip_text_printing()
	text_processor.time_since_done_printing += post_print_lock_time #Skip also skips the lock that locks it from.. well.. skipping

func set_visible(set_visible : bool):
	pass

func set_text(pre_processed_text : String):
	var text = text_processor.prepare_text(pre_processed_text)
	dynamic_dialogue_text_label.text = text
	static_dialogue_text_label.text = text
	recalculate_dynamic_window_size(4)
	#Also resize and stuff here..

func set_scale_alpha_multiplier(_scale_multiplier : float, _alpha_multiplier : float):
	scale_multiplier = _scale_multiplier
	alpha_multiplier = _alpha_multiplier

func set_show_dialogue(shown : bool):
	dialogue_state_target = 1.0 if shown else 0.0
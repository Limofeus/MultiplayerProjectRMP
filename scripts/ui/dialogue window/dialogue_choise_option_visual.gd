extends Node
class_name DialogueChoiceOptionVisual

@export var selected_selector_size = 44.0
@export var unselected_selector_size = 28.0

@export var lerp_lambda = 10.0

@export var option_text : RichTextLabel = null

@export var deselected_rect : TextureRect = null
@export var selected_rect : TextureRect = null
@export var arrow_rect : TextureRect = null

@export var min_size_scaler : Control = null

var _is_selected : bool = false
var _cur_selection_factor : float = 0.0

func _process(delta):
	_cur_selection_factor = StaticUtility.lerp_dampen(_cur_selection_factor, 1.0 if _is_selected else 0.0, lerp_lambda, delta)
	
	min_size_scaler.custom_minimum_size.x = lerp(unselected_selector_size, selected_selector_size, _cur_selection_factor)
	
	deselected_rect.scale = Vector2.ONE * (1.0 - _cur_selection_factor)
	selected_rect.scale = Vector2.ONE * _cur_selection_factor
	arrow_rect.scale = Vector2.ONE * _cur_selection_factor

	deselected_rect.self_modulate.a = 1.0 - _cur_selection_factor
	#selected_rect.self_modulate.a = _cur_selection_factor
	#arrow_rect.self_modulate.a = _cur_selection_factor

func set_selected(is_selected : bool):
	_is_selected = is_selected

func set_text(text : String):
	option_text.text = text
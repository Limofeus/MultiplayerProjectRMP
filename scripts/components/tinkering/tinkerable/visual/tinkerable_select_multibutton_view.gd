extends TinkerableMultibuttonView
class_name TinkerableSelectMultibuttonView

@export var selector_control : Control = null

@export var lerp_lambda : float = 10.0

var target_button_index : int = 0

func _process(delta):
	selector_control.global_position = StaticUtility.lerp_dampen(selector_control.global_position, button_view_array[target_button_index].global_position, lerp_lambda, delta)

func change_selected_button(new_selected_button_index : int) -> void:
	target_button_index = new_selected_button_index

func tinkerable_state_changed(new_state : Tinkerable.TinkerableState) -> void:
	super(new_state)
	selector_control.visible = new_state == Tinkerable.TinkerableState.Focused
extends Control

@export var menu_hover_rect : MenuButtonHoverRect

func trigger_hover():
	menu_hover_rect.set_pos_target(global_position.y)
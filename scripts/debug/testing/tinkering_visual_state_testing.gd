extends Node

@export var tinkerable : Tinkerable = null

@export var focused_node : Control = null
@export var unfocused_node : Control = null
@export var hidden_node : Control = null

func _ready():
	tinkerable.on_tinkerable_state_changed.connect(upd_state_visual)
	upd_state_visual(tinkerable.current_tinkerable_state)

func upd_state_visual(new_state : Tinkerable.TinkerableState):
	focused_node.visible = new_state == Tinkerable.TinkerableState.Focused
	unfocused_node.visible = new_state == Tinkerable.TinkerableState.Unfocused
	hidden_node.visible = new_state == Tinkerable.TinkerableState.Hidden

extends EntityComponent

@export var node_to_make_visible : Node
@export var visible_to_owner : bool = true

func _ready():
	node_to_make_visible.visible = visible_to_owner

func _notification(what):
	if what == NOTIFICATION_ENABLED:
		node_to_make_visible.visible = visible_to_owner
	if what == NOTIFICATION_DISABLED:
		node_to_make_visible.visible = !visible_to_owner

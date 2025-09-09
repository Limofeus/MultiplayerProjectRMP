extends DialogueTrigger
class_name CollisionAreaDialogueTrigger

@export var collision_area : Area3D = null
@export var colliding_group : String = ""

func _ready():
	collision_area.body_entered.connect(_on_body_entered)
	#collision_area.body_exited.connect(_on_body_exited), idk, maybe add this later

func _on_body_entered(body):
	print("body entered: " + body.name)
	if body.is_in_group(colliding_group):
		fire_dialogue_trigger()

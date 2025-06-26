extends DialogueTrigger
class_name CollisionAreaDialogueTrigger

@export var collision_area : Area3D = null
@export var colliding_group : String = ""

signal start_dialogue(sequence_name : String, priority : int)

func _ready():
	collision_area.body_entered.connect(_on_body_entered)
	#collision_area.body_exited.connect(_on_body_exited), idk, maybe add this later

func _on_body_entered(body):
	if body.is_in_group(colliding_group):
		start_dialogue.emit(sequence_name, dialogue_priority)
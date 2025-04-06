extends Interaction
class_name EntityEnteredInteraction

var node_entered : Node3D

func _init(set_node_entered : Node3D, set_interaction_priority : int = 0):
	if set_node_entered == null:
		print("Warning: No node entered found for projectile entered interaction")
	node_entered = set_node_entered
	authority_interaction_priority = set_interaction_priority
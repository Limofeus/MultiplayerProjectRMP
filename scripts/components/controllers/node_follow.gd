extends EntityComponent
class_name NodeFollowComponent

@export var follower_node : Node3D
@export var target_node : Node3D

func _process(delta):
	follower_node.global_position = target_node.global_position
	follower_node.global_rotation = target_node.global_rotation

extends EntityEnteredInteraction
class_name ProjectileEnteredInteraction

var projectile_component : ProjectileComponent
var collision_point : Vector3

func _init(set_node_entered : Node3D = null, set_projectile_component : ProjectileComponent = null, set_collision_point : Vector3 = Vector3.ZERO, set_interaction_priority : int = 0):
	if set_projectile_component == null:
		print("Warning: No projectile component found for projectile entered interaction")
	projectile_component = set_projectile_component
	collision_point = set_collision_point
	super(set_node_entered, set_interaction_priority)
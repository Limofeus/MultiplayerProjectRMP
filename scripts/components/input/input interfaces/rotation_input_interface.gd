extends EntityComponent
class_name RotationInputInterface

@export var auto_rotate_head : bool = false
@export var auto_rotate_speed : float = 999999.9 #Radian per second
@export var head_node_to_rotate : Node3D
@export var look_node_to_rotate : Node3D

var desired_rotation_direction : Vector3 = Vector3.FORWARD
var rotation_vector : Vector3 = Vector3.FORWARD

func _process(delta):
	if auto_rotate_head:
		rotation_vector = StaticUtility.rotate_towards(rotation_vector, desired_rotation_direction, auto_rotate_speed * delta)
		#var flat_rotation_vector = Vector3(rotation_vector.x, 0, rotation_vector.z).normalized()
		var flat_rotation_vector = Plane(head_node_to_rotate.global_basis.y, head_node_to_rotate.global_position).project(-rotation_vector).normalized()
		head_node_to_rotate.global_rotation.y = atan2(flat_rotation_vector.x, flat_rotation_vector.z)
		look_node_to_rotate.global_rotation.x = head_node_to_rotate.global_basis.z.signed_angle_to(-rotation_vector, head_node_to_rotate.global_basis.x)

	#Я бы сказал, что в этом коде нету минусов, но поскольку в годоте вектор, который смотрит в перёд отрицательный, минусы в этом коде нужны...

	#DebugDraw3D.draw_arrow(head_node_to_rotate.global_position, head_node_to_rotate.global_position + desired_rotation_direction, Color.ORANGE)
	#DebugDraw3D.draw_arrow(head_node_to_rotate.global_position, head_node_to_rotate.global_position + rotation_vector, Color.RED)
	#DebugDraw3D.draw_arrow(head_node_to_rotate.global_position, head_node_to_rotate.global_position - head_node_to_rotate.global_basis.z, Color.GREEN)

func get_rotation_vector() -> Vector3:
	return rotation_vector
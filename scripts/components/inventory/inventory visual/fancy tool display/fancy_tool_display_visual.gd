extends Node
class_name FancyToolDisplayVisual

@export var magic_circle_node : Node3D
@export var magic_circle_material : ShaderMaterial

@export var tool_rotator_node : Node3D
@export var tool_holder_node : Node3D

var fancy_tool_scale_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)
var fancy_tool_rotation_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)

@export var item_selected_circle_spin_speed : float = 5.0
@export var item_selected_visual_spin_speed : float = 5.0
@export var item_selected_visual_size : float = 1.0

@export var item_used_scale_spring_velocity_bump : float = 10.0
@export var item_used_rotation_spring_velocity_bump : float = 15.0

@export var item_changed_scale_spring_velocity_bump : float = 4.0
@export var item_changed_rotation_spring_velocity_bump : float = 3.0

@export var scale_spring_freq : float = 25.0
@export var scale_spring_damping : float = 0.7

@export var rotation_spring_freq : float = 5.0
@export var rotation_spring_damping : float = 0.6

var target_spring_pos : float = 0.0

func _ready():
	pass

func item_selected(item_visual_scene : PackedScene):
	if target_spring_pos == 1.0:
		bump_velocities(item_changed_scale_spring_velocity_bump, item_changed_rotation_spring_velocity_bump)
	target_spring_pos = 1.0

	for node in tool_holder_node.get_children():
		node.queue_free()

	tool_holder_node.add_child(item_visual_scene.instantiate())
	tool_holder_node.get_child(0).rotation = Vector3.ZERO

func item_deselected():
	target_spring_pos = 0.0

func item_used():
	bump_velocities(item_used_scale_spring_velocity_bump, item_used_rotation_spring_velocity_bump)

func bump_velocities(scale_spring_vel : float, rotation_spring_vel : float):
	fancy_tool_scale_spring.vel += scale_spring_vel
	fancy_tool_rotation_spring.vel += rotation_spring_vel

func _process(delta):
	SpringUtility.UpdateSpring(fancy_tool_scale_spring, target_spring_pos, delta, scale_spring_freq, scale_spring_damping)
	SpringUtility.UpdateSpring(fancy_tool_rotation_spring, target_spring_pos, delta, rotation_spring_freq, rotation_spring_damping)

	magic_circle_node.rotate_object_local(Vector3.UP, item_selected_circle_spin_speed * delta * fancy_tool_rotation_spring.pos)
	magic_circle_material.set_shader_parameter("alpha_mult", clampf(fancy_tool_scale_spring.pos, 0.0, 1.0))

	tool_rotator_node.rotate_object_local(Vector3.UP, item_selected_visual_spin_speed * delta * fancy_tool_rotation_spring.pos)
	tool_holder_node.scale = Vector3.ONE * max(fancy_tool_scale_spring.pos, 0.0) * item_selected_visual_size
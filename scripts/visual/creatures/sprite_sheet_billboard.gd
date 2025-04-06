extends Node3D
class_name SpriteSheetBillboard

@export var cur_sprite_sheet : OmnidirectionalSpriteSheet
@export var cycle_speed_mult : float = 10.0 #Frames per second

@export var billboard_node : Node3D
@export var billboard_material : ShaderMaterial

var billboard_target_node : Node3D
var frame_timer : float = 0

var cycle_speed : float = 1.0 #This one's now internal cus it gets updated by other stuff

func _ready():
	billboard_target_node = get_viewport().get_camera_3d() #TODO: make this update on camera change ig.. or something liek that
	update_sprite_sheet(cur_sprite_sheet) #Updates shader parameters

func update_sprite_sheet(new_sprite_sheet : OmnidirectionalSpriteSheet):
	cur_sprite_sheet = new_sprite_sheet
	billboard_material.set_shader_parameter("sprite_sheet", cur_sprite_sheet.texture)
	billboard_material.set_shader_parameter("sprite_sheet_rows", cur_sprite_sheet.dir_count)
	billboard_material.set_shader_parameter("sprite_sheet_columns", cur_sprite_sheet.frame_count)
	if cur_sprite_sheet.reset_timer:
		frame_timer = 0.0

func _process(delta : float):
	frame_timer += delta * cycle_speed * cycle_speed_mult * cur_sprite_sheet.cycle_speed_mult

	if not visible:
		return

	var target_look_vector : Vector3 = billboard_target_node.global_position
	target_look_vector.y = billboard_node.global_position.y

	if billboard_node.global_position != target_look_vector:
		billboard_node.look_at(target_look_vector, Vector3.UP)
	
	var angle_diff : float = (-billboard_node.global_basis.z).signed_angle_to(-global_basis.z, Vector3.UP) #Used to switch rendered sprite
	
	angle_diff = -(angle_diff / (2 * PI) * cur_sprite_sheet.dir_count)
	angle_diff = floor(angle_diff + 0.5)

	billboard_material.set_shader_parameter("sprite_sheet_pos", Vector2(floor(frame_timer), angle_diff))
	
	#Godot's QUAD mesh faces Z+, so we need to rotate it 180 degrees
	billboard_node.rotate_object_local(Vector3.UP, PI)

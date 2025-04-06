extends EntityComponent

@export var movement_input_interface : MovementInputInterface
@export var character_body : CharacterBody3D
@export var sprite_sheet_billboard : SpriteSheetBillboard

@export var move_speed_mult : float = 0.1
@export var idle_cycle_speed : float = 1.0

@export var fwd_move_sprite_sheet : OmnidirectionalSpriteSheet
@export var bwd_move_sprite_sheet : OmnidirectionalSpriteSheet

@export var sidestep_left_sprite_sheet : OmnidirectionalSpriteSheet
@export var sidestep_right_sprite_sheet : OmnidirectionalSpriteSheet

@export var idle_sprite_sheet : OmnidirectionalSpriteSheet

var cached_vector : Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if network_entity.has_authority():
		calculate_and_update_sprite_sheet()

func calculate_and_update_sprite_sheet():
	var send_vector : Vector2 = movement_input_interface.get_movement_vector() * character_body.velocity.length()

	if cached_vector != send_vector:
		cached_vector = send_vector
		sync_update_sheet.rpc(send_vector)

func try_change_sprite_sheet(new_sprite_sheet : OmnidirectionalSpriteSheet):
	if sprite_sheet_billboard.cur_sprite_sheet == new_sprite_sheet:
		return
	sprite_sheet_billboard.update_sprite_sheet(new_sprite_sheet)

func upd_axis_sprite_sheet(speed_value : float, positive_sprite_sheet : OmnidirectionalSpriteSheet, negative_sprite_sheet : OmnidirectionalSpriteSheet):
	if speed_value > 0:
		try_change_sprite_sheet(positive_sprite_sheet)
	elif speed_value < 0:
		try_change_sprite_sheet(negative_sprite_sheet)
	sprite_sheet_billboard.cycle_speed = abs(speed_value * move_speed_mult)

@rpc("call_local", "any_peer", "unreliable_ordered")
func sync_update_sheet(movement_vector : Vector2):
	var forward_move_speed : float = movement_vector.dot(movement_input_interface.M_FORWARD)
	var rightward_move_speed : float = movement_vector.dot(movement_input_interface.M_RIGHTWARD)

	if forward_move_speed == 0.0 and rightward_move_speed == 0.0:
		try_change_sprite_sheet(idle_sprite_sheet)
		sprite_sheet_billboard.cycle_speed = idle_cycle_speed
	elif abs(forward_move_speed) >= abs(rightward_move_speed):
		upd_axis_sprite_sheet(forward_move_speed, fwd_move_sprite_sheet, bwd_move_sprite_sheet)
	else:
		upd_axis_sprite_sheet(rightward_move_speed, sidestep_right_sprite_sheet, sidestep_left_sprite_sheet)

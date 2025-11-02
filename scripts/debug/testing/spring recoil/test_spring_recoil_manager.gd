@tool
extends Node

@export var forward_view_visual : Node2D = null
@export var side_view_visual : Node2D = null

@export var fire_cooldown : float = 0.1

@export_tool_button("Calc backwards recoil multiplier", "Callable") var calc_multiplier_button = calc_backwards_recoil_multiplier

@export_group("Recoil")
@export var vertical_recoil : float = 10.0
@export var vertical_recoil_randomness : float = 0.5
@export var horizontal_recoil : float = 0.5
@export var horizontal_recoil_randomness : float = 1.0
@export var backwards_recoil : float = 60.0
@export var backwards_recoil_randomness : float = 0.0

@export var backwards_pos_to_horizontal_recoil : Curve = null
@export var backwards_pos_to_horizontal_recoil_multiplier : float = 1.0
@export var backwards_recoil_curve_sample_multiplier : float = 1.0

@export_group("Visual")
@export var pos_scale_factor : float = 100.0
@export var rot_scale_factor : float = 20.0

@export_group("Spring")
@export var up_down_spring_freq : float = 12.0
@export var up_down_spring_damping : float = 1.0

@export var right_left_spring_freq : float = 12.0
@export var right_left_spring_damping : float = 1.0

@export var back_forward_spring_freq : float = 60.0
@export var back_forward_spring_damping : float = 5.0

var up_down_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)
var right_left_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)
var back_forward_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)

var fire_timer : float = 0.0

func _process(delta):
	check_fire(delta)
	update_springs(delta)
	update_sprites()

func update_springs(delta : float):
	SpringUtility.UpdateSpring(back_forward_spring, 0.0, delta, back_forward_spring_freq, back_forward_spring_damping)
	SpringUtility.UpdateSpring(up_down_spring, 0.0, delta, up_down_spring_freq, up_down_spring_damping)
	SpringUtility.UpdateSpring(right_left_spring, 0.0, delta, right_left_spring_freq, right_left_spring_damping)

func update_sprites():
	forward_view_visual.position = pos_scale_factor * Vector2(right_left_spring.pos, -up_down_spring.pos)
	side_view_visual.rotation_degrees = rot_scale_factor * up_down_spring.pos
	side_view_visual.position = pos_scale_factor * Vector2(back_forward_spring.pos, 0.0)

func check_fire(delta : float):
	if Input.is_action_pressed("ui_accept"):
		fire_timer += delta
		if fire_timer >= fire_cooldown:
			fire_timer -= fire_cooldown
			fire()

func calc_backwards_recoil_multiplier():
	var iter_count : int = 1000

	var max_backwards_pos : float = 0.0
	var average_backwards_pos : float = 0.0
	for i in range(iter_count):
		back_forward_spring.vel += backwards_recoil + randf_range(-backwards_recoil_randomness, backwards_recoil_randomness)
		SpringUtility.UpdateSpring(back_forward_spring, 0.0, fire_cooldown, back_forward_spring_freq, back_forward_spring_damping)
		max_backwards_pos = max(max_backwards_pos, back_forward_spring.pos)
		average_backwards_pos += back_forward_spring.pos
	average_backwards_pos /= iter_count
	print("Calculated max backwards pos: ", max_backwards_pos)
	print("Calculated average backwards pos: ", average_backwards_pos)
	print("Suggested multiplier: ", 1.0 / max_backwards_pos)


func fire():
	back_forward_spring.vel += backwards_recoil + randf_range(-backwards_recoil_randomness, backwards_recoil_randomness)
	
	right_left_spring.vel += backwards_pos_to_horizontal_recoil.sample(back_forward_spring.pos * backwards_recoil_curve_sample_multiplier) * backwards_pos_to_horizontal_recoil_multiplier
	
	up_down_spring.vel += vertical_recoil + randf_range(-vertical_recoil_randomness, vertical_recoil_randomness)
	right_left_spring.vel += horizontal_recoil + randf_range(-horizontal_recoil_randomness, horizontal_recoil_randomness)
	print(back_forward_spring.pos)
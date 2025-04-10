extends EntityComponent

@export var floater_character_body : CharacterBody3D = null
@export var floater_raycast : RayCast3D = null
@export var process_enabler : ProcessEnableSpawnComponent = null

@export var floater_planar_velocity_slowdown : float = 2.0
@export var target_height : float = 1.0
@export var height_to_vel_coef : float = 0.75
@export var no_hit_gravity : float = 20.0

@export var start_velocity : Vector3 = Vector3.ZERO

func _ready():
	process_enabler.nodes_enabled.connect(set_start_velocity)

func set_start_velocity():
	if network_entity.has_authority():
		floater_character_body.velocity = floater_character_body.global_basis * start_velocity
		print("SVS :" + str(floater_character_body.velocity))

func _physics_process(delta):
	var old_vel : Vector3 = floater_character_body.velocity
	var planar_velocity : Vector2 = Vector2(old_vel.x, old_vel.z)
	var vertical_velocity : float = old_vel.y
	
	floater_raycast.global_rotation = Vector3.ZERO

	planar_velocity = StaticUtility.lerp_dampen(planar_velocity, Vector2.ZERO, floater_planar_velocity_slowdown, delta)

	if floater_raycast.is_colliding():
		var collision_pont : Vector3 = floater_raycast.get_collision_point()
		var collision_dist = collision_pont.distance_to(floater_character_body.global_position)
		var height_diff = target_height - collision_dist
		vertical_velocity = height_diff * height_to_vel_coef
	else:
		vertical_velocity -= no_hit_gravity * delta

	floater_character_body.velocity = Vector3(planar_velocity.x, vertical_velocity, planar_velocity.y)

	floater_character_body.move_and_slide()
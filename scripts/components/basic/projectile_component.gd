extends InteractionRecievingComponent
class_name ProjectileComponent

#TODO: Look in to this, maybe there's a way to separate the damaging and the position changing properties of projectiles

@export var projectile_node : Node3D
@export var shape_cast : ShapeCast3D
@export var entity_destruction_component : DestructionComponent

@export var only_update_pos_on_owner : bool = true

@export var velocity : Vector3 = Vector3.ZERO #m/s RELATIVE / LOCAL, TODO: add a way to set it from global velocity
@export var vel_dot_product_threshold : float = -1.0 #Dot product between velocity and (proj->collision point vevctor), 0.0 = 180 degree collision angle, -1.0 = any collision will register
@export var dir_dot_product_threshold : float = -1.0 #Same as above, but for projectile forward vector instead of velocity

@export var projectile_lifetime : float = 5.0

@export var projectile_damage : DamageResource = null

var projectile_team : int = 0

var destroy_timer : float

var timer_started : bool = false
var projectile_lifetime_progress : float = 0.0 #Used for visual effects ranges from 0.0 to 1.0

var processed_collisions : Array[Node3D] = []

func start_destroy_timer() -> void:
	timer_started = true

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if interaction is EntityDestructionInteraction:
		destroy_if_owner()
	#TODO: Look in to other ways of destroying projectiles (To allow VFX and triggers upon destruction)

func _process(delta: float) -> void:
	if(timer_started):
		destroy_timer += delta

	if(destroy_timer >= projectile_lifetime and timer_started):
		destroy_if_owner()

	projectile_lifetime_progress = clamp(destroy_timer / projectile_lifetime, 0.0, 1.0)

func destroy_if_owner() -> void:
	if(network_entity.has_authority()):
		entity_destruction_component.destroy_entity()

func _physics_process(delta: float) -> void:
	var shape_cast_vector = velocity * delta #This should be length of shapecast (m/physics_process)
	shape_cast.target_position = shape_cast_vector
	shape_cast.force_shapecast_update()
	var hit = shape_cast.is_colliding()
	if(hit):
		for i in range(shape_cast.get_collision_count()):

			var collided_object : Node3D = shape_cast.get_collider(i)
			var collision_point : Vector3 = shape_cast.get_collision_point(i)

			if !processed_collisions.has(collided_object):
				#print("NEW collision with: " + collided_object.name)
				processed_collisions.append(collided_object) #TODO: Update list in such a way that it allows multiple collisions with one object
				process_collision_at_point(collided_object, collision_point)

	if((!only_update_pos_on_owner) or network_entity.has_authority()):
		projectile_node.position += projectile_node.basis * shape_cast_vector

func process_collision_at_point(collided_object : Node3D, collision_point : Vector3) -> void:
	var interacted_entity = StaticNetworkUtility.get_network_entity_from_node(collided_object)
	
	var diff_vector_normalized : Vector3 = (collision_point - projectile_node.global_position).normalized()
	var global_velocity_normalized : Vector3 = (projectile_node.global_transform.basis * velocity).normalized()

	#DebugDraw3D.draw_arrow(projectile_node.global_position, projectile_node.global_position + diff_vector_normalized, Color.GREEN, 0.01, true, 0.5)
	#DebugDraw3D.draw_arrow(projectile_node.global_position, projectile_node.global_position + global_velocity_normalized, Color.BLUE, 0.01, true, 0.5)
	#DebugDraw3D.draw_sphere(projectile_node.global_position, 0.1, Color.ORANGE, 0.5)
	#DebugDraw3D.draw_sphere(collision_point, 0.1, Color.RED, 0.5)
	
	var vel_dot_accept_collision : bool = diff_vector_normalized.dot(global_velocity_normalized) > vel_dot_product_threshold
	var dir_dot_accept_collision : bool = diff_vector_normalized.dot(-projectile_node.global_basis.z) > dir_dot_product_threshold
	
	if interacted_entity != null and vel_dot_accept_collision and dir_dot_accept_collision:
		network_entity.start_interaction(interacted_entity, ProjectileEnteredInteraction.new(collided_object, self, collision_point))
extends SpatialAttributes
class_name KillableAttributes

@export var max_health : float = 1.0
@export var health : float = 1.0
@export var team_id : int = 0

signal on_hit_by_projectile(projectile_position : Vector3)
signal on_take_damage(damage_ammount : float, damager_peer : int)
signal on_death()

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if interaction is ProjectileEnteredInteraction:
		process_projectile(interaction.projectile_component, interaction.collision_point)

func process_projectile(projectile : ProjectileComponent, collision_point : Vector3) -> void:
	if projectile != null and projectile.projectile_team != team_id:
		on_hit_by_projectile.emit(collision_point)
		process_damage(projectile.projectile_damage)

func process_damage(damage_resource : DamageResource) -> void:
	if damage_resource == null:
		return
	take_damage.rpc(damage_resource.damage_ammount, multiplayer.get_unique_id())

@rpc("any_peer", "call_local", "reliable")
func take_damage(damage_ammount : float, damager_peer : int) -> void:
	health -= damage_ammount
	on_take_damage.emit(damage_ammount, damager_peer)

	#print("Took damage on peer: " + str(multiplayer.get_unique_id()) + " health: " + str(health))
	#DebugDraw3D.draw_sphere(spatial_node.global_position, 0.75, Color.RED, 0.2)

	if health <= 0.0:
		on_death.emit()
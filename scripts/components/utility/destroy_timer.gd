extends EntityComponent

@export var entity_destruction_component : DestructionComponent
@export var destroy_timer : float = 0.0

func _process(delta):
	destroy_timer -= delta
	if destroy_timer <= 0.0:
		entity_destruction_component.destroy_entity()
extends Node

@export var killable_attributes : KillableAttributes
@export var main_healthbar : ProgressBar
@export var effect_healthbar : ProgressBar

@export var healthbar_lerp_dampen_lambda : float = 5.0

var healthbars_visible : bool = false

func _ready():
	killable_attributes.on_take_damage.connect(update_healthbars.unbind(2))
	main_healthbar.value = 1.0
	effect_healthbar.value = 1.0
	effect_healthbar.visible = healthbars_visible

func update_healthbars():
	healthbars_visible = killable_attributes.health > 0.0
	effect_healthbar.visible = healthbars_visible
	main_healthbar.value = killable_attributes.health / killable_attributes.max_health
	print("UPD HEalthbar Health: " + str(killable_attributes.health) + " / " + str(killable_attributes.max_health))

func _process(delta):
	if healthbars_visible:
		effect_healthbar.value = StaticUtility.lerp_dampen(effect_healthbar.value, killable_attributes.health / killable_attributes.max_health, healthbar_lerp_dampen_lambda, delta)



extends Node
class_name DamageablePart

@export var penetration_threshold : float = 0.0
@export var shatter_threshold : float = 0.0
@export var hardness_factor : float = 1.0
@export var max_hardness : float = 1.0
#TODO: IDK come up with some system to figure out how projectiles should interact with damageable parts

#As an idea, it could also be component based (eg. shatter component, penetrate component, etc.)
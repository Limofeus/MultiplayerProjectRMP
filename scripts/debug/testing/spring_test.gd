extends Sprite2D

@export var desPos : float = 0.0
@export var desPosVec : Vector2 = Vector2.UP * 300.0
var springParams = SpringUtility.SpringParams.new()
@export var freq : float = 5.0
@export var damp : float = 1.0

func _process(delta: float) -> void:
	position = lerp(Vector2.ZERO, desPosVec, springParams.pos)
	SpringUtility.UpdateSpring(springParams, desPos, delta, freq, damp)
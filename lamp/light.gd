extends OmniLight3D

@export var amount := 0.03
@export var smooth := 15.0

var origin: Vector3
var target: Vector3

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	if randf() < 0.3:
		target = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * amount
	position = position.lerp(origin + target, smooth * delta)

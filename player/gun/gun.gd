class_name Gun extends Node3D

@export var FIRE_POWER := 500.0

var projectile_scn = preload("res://player/gun/projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"fire"):
		fire()

func fire() -> void:
	var projectile: RigidBody3D = projectile_scn.instantiate()
	get_tree().get_root().add_child(projectile)
	projectile.global_transform.origin = global_transform.origin
	projectile.apply_impulse(-global_transform.basis.z * FIRE_POWER, Vector3(randf_range(0.0, 0.1), randf_range(0.0, 0.1), randf_range(0.0, 0.1)))
	

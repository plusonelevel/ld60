class_name Gun extends Node3D

@export var FIRE_POWER := 2.0

@onready var smoke : GPUParticles3D = $Smoke

var is_empty := true
var projectile_scn = preload("res://player/gun/projectile.tscn")

var priming_counter := 0
@export var prime_target := 3


var transforms: Dictionary[Enums.GunPosition, Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transforms = {
		Enums.GunPosition.DEFAULT: [position, rotation],
		Enums.GunPosition.EMPTY: [Vector3(0.4, -1.1, 0.2), Vector3(PI/4, PI/6, 0)],
		Enums.GunPosition.LOADED: [Vector3(0.4, -1, 0.13), Vector3(deg_to_rad(29), deg_to_rad(56), deg_to_rad(31))]
	}
	
	Signals.gun_fired.connect(_on_gun_fired)
	Signals.gun_loaded.connect(_on_gun_loaded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"fire") and GameManager.player_state == Enums.PlayerState.DEFAULT and GameManager.gun_state == Enums.GunState.PRIMED:
		fire()
	elif event.is_action_pressed(&"prime_gun") and GameManager.player_state == Enums.PlayerState.RELOADING and GameManager.gun_state == Enums.GunState.LOADED:
		prime()

func fire() -> void:
	Signals.gun_fired.emit()
	smoke.emitting = true
	smoke.restart()
	var projectile: Projectile = projectile_scn.instantiate()
	get_tree().get_root().add_child(projectile)
	projectile.global_transform.origin = global_transform.origin
	projectile.apply_impulse(-global_transform.basis.z * FIRE_POWER + Vector3(0, 1, 0), Vector3(randf_range(0.0, 0.1), randf_range(0.0, 0.1), randf_range(0.0, 0.1)))
	projectile.prime()

func start_reloading():
	var tween = create_tween().set_parallel()
	var values = transforms[Enums.GunPosition.EMPTY if is_empty else Enums.GunPosition.LOADED]
	tween.tween_property(self, ^"position", values[0], GameManager.reload_transition_length)
	tween.tween_property(self, ^"rotation", values[1], GameManager.reload_transition_length)
	
func stop_reloading():
	var tween = create_tween().set_parallel()
	tween.tween_property(self, ^"position", transforms[Enums.GunPosition.DEFAULT][0], GameManager.reload_transition_length)
	tween.tween_property(self, ^"rotation", transforms[Enums.GunPosition.DEFAULT][1], GameManager.reload_transition_length)

func prime():
	priming_counter += 1
	if priming_counter >= prime_target:
		priming_counter = 0
		Signals.gun_primed.emit()
			

func _on_gun_fired():
	is_empty = true

func _on_gun_loaded():
	is_empty = false
	start_reloading()

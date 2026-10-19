class_name Gun extends Node3D

@export var FIRE_POWER := 2.0

@onready var smoke : GPUParticles3D = $Smoke
@onready var tycinka : Node3D = $Tycinka
var tycinka_orig_pos: Vector3

var is_empty := true
var projectile_scn = preload("res://player/gun/projectile.tscn")

var priming_counter := 0
var can_prime := true
@export var prime_target := 4
@export var prime_duration := 0.15

enum GunPosition {
	DEFAULT,
	EMPTY,
	LOADED
}

var transforms: Dictionary[GunPosition, Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transforms = {
		GunPosition.DEFAULT: [position, rotation],
		GunPosition.EMPTY: [Vector3(0.4, -1.1, 0.2), Vector3(PI/4, PI/6, 0)],
		GunPosition.LOADED: [Vector3(0.4, -1, 0.13), Vector3(deg_to_rad(29), deg_to_rad(56), deg_to_rad(31))]
	}
	
	Signals.gun_state_changed.connect(_on_gun_state_changed)
	
	tycinka_orig_pos = tycinka.position


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"fire") and GameManager.player_state == Enums.PlayerState.DEFAULT and GameManager.gun_state == Enums.GunState.PRIMED:
		fire()
	elif event.is_action_pressed(&"prime_gun") and GameManager.player_state == Enums.PlayerState.RELOADING and GameManager.gun_state == Enums.GunState.LOADED:
		prime()

func fire() -> void:
	if not visible:
		return
	is_empty = true
	Signals.gun_state_changed.emit(Enums.GunState.DEFAULT)
	smoke.restart()
	var projectile: Projectile = projectile_scn.instantiate()
	get_tree().get_root().add_child(projectile)
	projectile.global_transform.origin = global_transform.origin
	projectile.apply_impulse(-global_transform.basis.z * FIRE_POWER + Vector3(0, 1, 0), Vector3(randf_range(0.0, 0.1), randf_range(0.0, 0.1), randf_range(0.0, 0.1)))
	projectile.prime()

func start_reloading():
	var tween = create_tween()
	var values: Array = transforms[GunPosition.EMPTY if is_empty else GunPosition.LOADED]
	tween.tween_property(self, ^"position", values[0], GameManager.reload_transition_length)
	tween.parallel().tween_property(self, ^"rotation", values[1], GameManager.reload_transition_length)
	if not is_empty:
		tween.tween_callback(tycinka.show)
	
	
func stop_reloading():
	tycinka.hide()
	var tween = create_tween().set_parallel()
	tween.tween_property(self, ^"position", transforms[GunPosition.DEFAULT][0], GameManager.reload_transition_length)
	tween.tween_property(self, ^"rotation", transforms[GunPosition.DEFAULT][1], GameManager.reload_transition_length)

func prime():
	if not can_prime:
		return
	
	can_prime = false
	var tween = create_tween()
	tween.tween_property(tycinka, ^"position", tycinka_orig_pos + Vector3(0.02, -0.015, 0.2), prime_duration)
	tween.tween_property(tycinka, ^"position", tycinka_orig_pos, prime_duration)
	tween.tween_callback(func():
		can_prime = true
		priming_counter += 1
		if priming_counter >= prime_target:
			priming_counter = 0
			Signals.gun_state_changed.emit(Enums.GunState.PRIMED)
	)

func _on_gun_state_changed(state: Enums.GunState):
	if state == Enums.GunState.LOADED:
		is_empty = false
		start_reloading()

	

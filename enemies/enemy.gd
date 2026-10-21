extends CharacterBody3D
class_name Enemy


var lamps_in_range: Array[Lamp] = []
@onready var health_label = $DebugHP
@onready var death_fx = $DeathFX
@onready var hit_sfx = $Hit
@onready var blood_fx = $Blood
@onready var death_sfx = $Death

@export var health : float = 10.0
@export var speed : float = 1.0
@export var light_dps : float = 10.0

@export var attack_range : float = 1.5
@export var attack_damage : float = 10.0
@export var attack_cooldown : float = 1.0
@export var blend_speed : float = 6.0


enum State { RUN, HIT, DIE}

var player: Player
var attack_timer := 0.0
var chasing := false


func _ready() -> void:
	player = get_tree().get_first_node_in_group(&"player")
	if health_label:
		health_label.hide()

func _physics_process(delta):
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()
	
	#CHASING PLAYER
	if not chasing:
		chasing = true

	if not chasing:
		velocity = Vector3.ZERO
		move_and_slide()
		return


	if dist > attack_range:
		velocity = to_player.normalized() * speed
		attack_timer = 0.0
	else:
		velocity = Vector3.ZERO
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_cooldown
			hit_player()

	move_and_slide()
	look_at(player.global_position, Vector3.UP)

	#TAKING DAMAGE FROM LIGHT
	var dmg := 0.0
	for lamp in lamps_in_range:
		dmg += light_dps * lamp.intensity / global_position.distance_to(lamp.position)
	take_dmg(dmg * delta)
	
		
func _process(delta):
	health_label.text = "%.1f" % health

func hit_player():
	if player.has_method("take_dmg"):
		player.take_dmg(attack_damage)

func take_dmg(dmg):
	health -= dmg
	if dmg > 0:
		blood_fx.emitting = true
	if health <= 0:
		die()

func play_hit():
	hit_sfx.play()

func die():
	Signals.enemy_died.emit(self)
	death_fx.reparent(get_tree().current_scene)  
	death_fx.emitting = true

	blood_fx.reparent(get_tree().current_scene)
	blood_fx.emitting = false

	if hit_sfx.playing:
		hit_sfx.reparent(get_tree().current_scene)
	death_sfx.play()
	if death_sfx.playing:
		death_sfx.reparent(get_tree().current_scene)
	queue_free()
	
	
func lamp_range_entered(lamp_pos: Lamp):
	lamps_in_range.append(lamp_pos)

func lamp_range_exited(lamp_pos: Lamp):
	lamps_in_range.erase(lamp_pos)

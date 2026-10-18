extends CharacterBody3D
class_name Enemy


var lamps_in_range: Array[Lamp] = []
@onready var health_label = $DebugHP
@onready var death_fx = $DeathFX

@export var health : float = 10.0
@export var speed : float = 1.0
@export var light_dps : float = 10.0

@export var attack_range : float = 1.5
@export var attack_damage : float = 2.0
@export var attack_cooldown : float = 1.0
@export var blend_speed : float = 6.0

@onready var anim_tree: AnimationTree = $ghost/AnimationTree
const BLEND_PATH := "parameters/Blend3/blend_amount"


enum State { RUN, HIT, DIE}

var player: Player
var state := State.RUN
var attack_timer := 0.0
var blend = 1.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group(&"player")

func _physics_process(delta):
	#CHASING PLAYER
	var to_player := player.global_position - global_position
	to_player.y = 0.0  # keep movement and rotation flat
	var dist := to_player.length()

	if dist > attack_range:
		state = State.RUN
		velocity = to_player.normalized() * speed
		attack_timer = 0.0  # hits immediately on arrival; set to attack_cooldown for a wind-up
	else:
		state = State.HIT
		velocity = Vector3.ZERO
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_cooldown
			hit_player()
	
	move_and_slide()
	look_at(player.global_transform.origin, Vector3.UP)

	#TAKING DAMAGE FROM LIGHT
	var dmg := 0.0
	for lamp in lamps_in_range:
		dmg += light_dps * lamp.intensity / global_position.distance_to(lamp.position)
	take_dmg(dmg * delta)
	
	_update_animation(delta)
		
func _process(delta):
	health_label.text = "%.1f" % health

func _update_animation(delta):
	var target := 1.0 if state == State.RUN else 0.0
	blend = move_toward(blend, target, blend_speed * delta)
	anim_tree.set(BLEND_PATH, blend)

func hit_player():
	if player.has_method("take_dmg"):
		player.take_dmg(attack_damage)

func take_dmg(dmg):
	health -= dmg
	if health <= 0:
		die()

func die():
	if state == State.DIE:
		return
	state = State.DIE

	death_fx.reparent(get_tree().current_scene)  
	death_fx.one_shot = true
	death_fx.emitting = true
	death_fx.finished.connect(death_fx.queue_free)

	queue_free()
	
	
func lamp_range_entered(lamp_pos: Lamp):
	lamps_in_range.append(lamp_pos)

func lamp_range_exited(lamp_pos: Lamp):
	lamps_in_range.erase(lamp_pos)

extends CharacterBody3D
class_name Enemy


var lamps_in_range: Array[Lamp] = []
@onready var health_label = $DebugHP

@export var health : float = 10.0
@export var speed : float = 1.0
@export var light_dps : float = 10.0

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group(&"player")

func _physics_process(delta):
	#CHASING PLAYER
	if not player:
		return
	
	var direction = (player.global_transform.origin - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()
	look_at(player.global_transform.origin, Vector3.UP)

	#TAKING DAMAGE FROM LIGHT
	var dmg := 0.0
	for lamp in lamps_in_range:
		dmg += light_dps * lamp.intensity / global_position.distance_to(lamp.position)
	take_dmg(dmg * delta)
		
		
func _process(delta):
	health_label.text = "%.1f" % health

func take_dmg(dmg):
	health -= dmg
	if health <= 0:
		die()

func die():
	queue_free()
	
func lamp_range_entered(lamp_pos: Lamp):
	lamps_in_range.append(lamp_pos)

func lamp_range_exited(lamp_pos: Lamp):
	lamps_in_range.erase(lamp_pos)

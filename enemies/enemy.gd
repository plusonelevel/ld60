extends CharacterBody3D
class_name Enemy


@onready var player = get_node("/root/Main/World/Player")
@onready var is_in_light_area = false
@onready var health_label = $DebugHP

@export var health : float = 10.0
@export var speed : float = 1.0
@export var light_dps : float = 2.0


func _physics_process(delta):
	#CHASING PLAYER
	if not player:
		return
	var direction = (player.global_transform.origin - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()
	look_at(player.global_transform.origin, Vector3.UP)
	
	#TAKING DAMAGE FROM LIGHT
	if is_in_light_area == true:
		take_dmg(light_dps * delta)
		
		
func _process(delta):
	health_label.text = str(health)

func take_dmg(dmg):
	health -= dmg
	if health <= 0:
		die()

func die():
	queue_free()

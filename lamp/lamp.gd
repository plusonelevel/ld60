extends StaticBody3D

@export var fade_time := 5.0

@onready var interactive_area: Area3D = $InteractiveArea
@onready var light_source: OmniLight3D = $Light
@onready var light_collider: CollisionShape3D = $LightArea/CollisionShape3D

var orig_energy
var orig_size
var tween: Tween

var MIN_SCALE := Vector3(0.01, 0.01, 0.01)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orig_energy = light_source.light_energy
	orig_size = light_collider.scale
	light_source.light_energy = 0.0
	light_collider.scale = MIN_SCALE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interactive_area_body_entered(body: Node3D) -> void:
	if body is Player:
		light_up()
		Signals.interactable_changed.emit(true)


func _on_interactive_area_body_exited(body: Node3D) -> void:
	if body is Player:
		Signals.interactable_changed.emit(false)


func light_up():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(light_source, ^"light_energy", orig_energy, 0.5)
	tween.parallel().tween_property(light_collider, ^"scale", orig_size, 0.5)
	
	tween.tween_property(light_source, ^"light_energy", 0.0, fade_time)
	tween.parallel().tween_property(light_collider, ^"scale", MIN_SCALE, fade_time)
	

func _on_light_area_body_entered(body) -> void:
	if body is Enemy:
		print_debug("Enemy %s in range of lamp %s" % [body.name, name])
		body.is_in_light_area = true


func _on_light_area_body_exited(body) -> void:
	if body is Enemy:
		body.is_in_light_area = false

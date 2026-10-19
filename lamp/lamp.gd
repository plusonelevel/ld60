class_name Lamp extends StaticBody3D

@export var lamp_id : int

@onready var interactive_area: Area3D = $InteractiveArea
@onready var light_source: OmniLight3D = $Light
@onready var light_collider: CollisionShape3D = $LightArea/CollisionShape3D
@onready var flame: GPUParticles3D = $Flame
@onready var controls := $LampControls
@onready var lamp_sound = $LampSound

var orig_energy
var intensity
var fade_time

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orig_energy = light_source.light_energy
	intensity = 0.0
	controls.pressure_full.connect(_on_pressure_full)
	fade_time = controls.fill_time + controls.drain_time
	#fade_time = 5000.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	light_source.light_energy = intensity * orig_energy


func light_up():
	Signals.lamp_lit.emit(lamp_id)
	lamp_sound.play()
	flame.emitting = true
	flame.amount_ratio = 1.0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, ^"intensity", 1.0, 0.5)
	
	tween.tween_property(self, ^"intensity", 0.0, fade_time)
	tween.parallel().tween_property(flame, ^"amount_ratio", 0.0, fade_time)
	tween.parallel().tween_property(lamp_sound, ^"playing", false, fade_time)
	tween.tween_callback(func(): flame.emitting = false)
	

func _on_light_area_body_entered(body) -> void:
	if body is Enemy:
		print_debug("Enemy %s in range of lamp %s" % [body.name, name])
		body.lamp_range_entered(self)


func _on_light_area_body_exited(body) -> void:
	if body is Enemy:
		print_debug("Enemy %s left range of lamp %s" % [body.name, name])
		body.lamp_range_exited(self)

func _on_pressure_full():
	light_up()

extends StaticBody3D

@export var fade_time := 5.0

@onready var interactive_area: Area3D = $InteractiveArea
@onready var light_source: OmniLight3D = $Light
@onready var light_area_collider: CollisionShape3D = $LightArea/CollisionShape3D

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interactive_area_body_entered(body: Node3D) -> void:
	if body is Player:
		light()
		Signals.interactable_changed.emit(true)


func _on_interactive_area_body_exited(body: Node3D) -> void:
	if body is Player:
		Signals.interactable_changed.emit(false)


func light():
	if tween:
		tween.stop()
	tween = create_tween()
	tween.tween_property(light_source, ^"light_energy", 2, 0.5)
	tween.parallel().tween_property(light_area_collider, ^"scale", Vector3.ONE, 0.5)
	
	tween.tween_property(light_source, ^"light_energy", 0, fade_time)
	tween.parallel().tween_property(light_area_collider, ^"scale", Vector3.ZERO, fade_time)
	

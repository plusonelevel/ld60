extends StaticBody3D

@onready var interactive_area: Area3D = $InteractiveArea
@onready var light_source: OmniLight3D = $Light
@onready var light_area_collider := $LightArea/CollisionShape3D

var original_energy
@export var is_on := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_energy = light_source.light_energy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interactive_area_body_entered(body: Node3D) -> void:
	if body is Player:
		toggle()
		Signals.interactable_changed.emit(true)


func _on_interactive_area_body_exited(body: Node3D) -> void:
	if body is Player:
		Signals.interactable_changed.emit(false)


func toggle() -> bool:
	is_on = !is_on
	var tween = get_tree().create_tween()
	tween.tween_property(light_source, ^"light_energy", 0 if !is_on else original_energy, 1.5)
	light_area_collider.set_deferred(&"disabled", !is_on)
	return is_on

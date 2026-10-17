extends StaticBody3D

@onready var interactive_area: Area3D = $InteractiveArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interactive_area_body_entered(body: Node3D) -> void:
	if body is Player:
		Signals.interactable_changed.emit(true)


func _on_interactive_area_body_exited(body: Node3D) -> void:
	if body is Player:
		Signals.interactable_changed.emit(false)

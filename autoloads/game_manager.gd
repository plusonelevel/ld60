extends Node



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.interactable_changed.connect(test)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func test(x: bool):
	print_debug("test: player %s interactive area" % ["entered" if x else "exited"])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()

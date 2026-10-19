extends Node

const LAST_LAMP_ID := 6

func _ready() -> void:
	await get_tree().process_frame
	Signals.lamp_lit.emit(0)
	Signals.lamp_lit.connect(_on_lamp_lit)

func _on_lamp_lit(id):
	if id == LAST_LAMP_ID:
		Signals.win.emit()

extends Node

func _ready() -> void:
	await get_tree().process_frame
	Signals.lamp_lit.emit(0)

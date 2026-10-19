extends Node3D

var _starting := false

func _unhandled_input(event: InputEvent) -> void:
	if _starting:
		return
	if event is InputEventKey and event.pressed and not event.echo \
			and event.physical_keycode == KEY_E:
		_starting = true
		get_tree().change_scene_to_file("res://scenes/main.tscn")

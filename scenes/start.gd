extends Node3D

var main_scn = load("res://scenes/main.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()
	elif event is InputEventMouseButton:
		get_tree().change_scene_to_packed(main_scn)

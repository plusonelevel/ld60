extends Control

@onready var click = $"../Click"

var _leaving := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for button in find_children("*", "BaseButton"):
		button.mouse_entered.connect(_play_hover)

func _play_hover() -> void:
	click.pitch_scale = 1.0
	click.play()

func _play_click() -> void:
	click.pitch_scale = 0.8
	click.play()

func _go_to(scene: String) -> void:
	if _leaving:
		return
	_leaving = true
	_play_click()
	await click.finished
	get_tree().change_scene_to_file(scene)


func _on_play_pressed() -> void:
	_go_to("res://scenes/main.tscn")


func _on_tutorial_pressed() -> void:
	_go_to("res://scenes/tutorial.tscn")

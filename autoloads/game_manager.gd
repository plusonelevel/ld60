extends Node

var player_state := Enums.PlayerState.DEFAULT
var gun_state := Enums.GunState.DEFAULT

const reload_transition_length := 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.player_state_changed.connect(_on_player_state_changed)
	Signals.gun_state_changed.connect(_on_gun_state_changed)
	
	await get_tree().process_frame


func _on_player_state_changed(new_state):
	player_state = new_state

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()

func _on_gun_state_changed(new_state: Enums.GunState):
	gun_state = new_state

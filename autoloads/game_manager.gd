extends Node

var player_state := Enums.PlayerState.DEFAULT
var gun_state := Enums.GunState.DEFAULT

var reload_transition_length := 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.player_state_changed.connect(_on_player_state_changed)
	Signals.gun_fired.connect(_on_gun_state_changed.bind(Enums.GunState.DEFAULT))
	Signals.gun_loaded.connect(_on_gun_state_changed.bind(Enums.GunState.LOADED))
	Signals.gun_primed.connect(_on_gun_state_changed.bind(Enums.GunState.PRIMED))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_state_changed(new_state):
	player_state = new_state

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()

func _on_gun_state_changed(new_state: Enums.GunState):
	gun_state = new_state

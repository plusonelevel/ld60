extends Node

class CursorOptions:
	var default: Resource
	var active: Resource
	func _init(def: Resource, act: Resource):
		default = def
		active = act

var cursor_default = CursorOptions.new(
	load("res://assets/2d/cursor_select.png"),
	load("res://assets/2d/cursor_select_tap.png")
)

var cursor_hand = CursorOptions.new(
	load("res://assets/2d/cursor_grab.png"),
	load("res://assets/2d/cursor_grabbing.png")
)

var cursor: CursorOptions

var click_timer: Timer

func set_default():
	Input.set_custom_mouse_cursor(cursor.default)

func set_active():
	Input.set_custom_mouse_cursor(cursor.active)


func _ready():
	Signals.player_state_changed.connect(_on_player_state_changed)
	
	cursor = cursor_default
	set_default()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			set_active()
		else:
			set_default()
			
func _on_player_state_changed(new_state: Enums.PlayerState):
	if new_state == Enums.PlayerState.RELOADING:
		cursor = cursor_hand
		set_default()
	else:
		cursor = cursor_default
		set_default()

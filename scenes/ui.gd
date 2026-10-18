extends Control


@onready var status = $StatusMessage
@onready var crosshair = $Crosshair
@onready var kerosene_charges = $Kerosene/Charges
@onready var gun_status = $Gun/GunStatus

var tween: Tween

func _ready() -> void:
	Signals.status_message.connect(_status_message_change)
	Signals.player_state_changed.connect(_on_player_state_changed)
	Signals.kerosene_amount_changed.connect(_on_kerosene_amount_changed)
	Signals.gun_state_changed.connect(_on_gun_state_changed)
	
	_on_gun_state_changed(Enums.GunState.DEFAULT)
	
func _status_message_change(msg):
	status.text = msg
	status.modulate.a = 1.0
	status.show()	
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(status, ^"modulate:a", 0.0, 0.3)
	tween.tween_callback(status.hide)

func _on_player_state_changed(state):
	if state == Enums.PlayerState.RELOADING:
		crosshair.hide()
	else:
		crosshair.show()

func _on_kerosene_amount_changed(amount):
	kerosene_charges.text = " * ".repeat(amount) + " _ ".repeat(Player.KEROSENE_CAPACITY - amount)

func _on_gun_state_changed(state: Enums.GunState):
	if state == Enums.GunState.LOADED:
		gun_status.text = "Loaded"
	elif state == Enums.GunState.PRIMED:
		gun_status.text = "READY"
	else:
		gun_status.text = "Empty"

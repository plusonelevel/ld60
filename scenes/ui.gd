extends Control


@onready var status = $StatusMessage
<<<<<<< HEAD
@onready var player = $"../World/Player"
@onready var courage_bar = $CourageBar
@onready var kerosene_bar = $KeroseneBar
=======
@onready var crosshair = $Crosshair
@onready var kerosene_charges = $Kerosene/Charges
@onready var gun_status = $Gun/GunStatus
>>>>>>> 8451985c60f3d99e8c18d590509a65cf6303acc5

var tween: Tween
var courage_tween: Tween
var kerosene_tween: Tween
var last_health
var last_kerosene

func _ready() -> void:
	Signals.status_message.connect(_status_message_change)
	Signals.player_state_changed.connect(_on_player_state_changed)
	Signals.kerosene_amount_changed.connect(_on_kerosene_amount_changed)
	Signals.gun_state_changed.connect(_on_gun_state_changed)
	
	_on_gun_state_changed(Enums.GunState.DEFAULT)
	
func _process(delta: float) -> void:
	if player.health != last_health:
		last_health = player.health
		courage_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		courage_tween.tween_property(courage_bar, "value", player.health, 0.3)

	if player.kerosene_amount != last_kerosene:
		last_kerosene = player.kerosene_amount
		kerosene_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		kerosene_tween.tween_property(kerosene_bar, "value", player.kerosene_amount, 1.0)
	
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

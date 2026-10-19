extends Node

@onready var tut_steps := $TutorialSteps
var current_idx := 0
var total_steps : int

var countdown := 5.0
@onready var countdown_label = $TutorialSteps/Step10/Countdown

@onready var spawner_walking : Spawner = $World/Spawner
@onready var spawner_flying : Spawner = $World/Spawner2

var main_scn = load("res://scenes/main.tscn")

func _ready() -> void:
	total_steps = tut_steps.get_child_count()
	_on_tutorial_advanced(current_idx)
	Signals.tutorial_advanced.connect(_on_tutorial_advanced)
	Signals.kerosene_toggled.connect(_on_kerosene_toggled)
	Signals.kerosene_amount_changed.connect(_on_kerosene_amount_changed)
	Signals.lamp_door_opened.connect(_on_lamp_door_opened)
	Signals.lamp_lit.connect(_on_lamp_lit)
	Signals.enemy_died.connect(_on_enemy_died)
	Signals.player_state_changed.connect(_on_player_state_changed)
	Signals.gun_state_changed.connect(_on_gun_state_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and OS.get_name() != "Web":
		get_tree().quit()


func advance_tutorial():
	current_idx += 1
	if current_idx >= total_steps:
		get_tree().change_scene_to_packed(main_scn)
	else:
		Signals.tutorial_advanced.emit(current_idx)

func _on_kerosene_toggled(_is_equipped):
	if current_idx == 0:
		advance_tutorial()
		
func _on_kerosene_amount_changed(_amount: int):
	if current_idx == 1:
		advance_tutorial()

func _on_lamp_door_opened(_is_open):
	if current_idx == 2:
		advance_tutorial()

func _on_lamp_lit(_id):
	if current_idx == 3:
		advance_tutorial()
		var tween = create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(func(): spawner_flying._on_spawn_timer_timeout())

func _on_enemy_died(enemy):
	if enemy and current_idx == 4:
		advance_tutorial()
	elif enemy and current_idx == 8:
		advance_tutorial()
		var timer = Timer.new()
		timer.wait_time = 1.0
		timer.one_shot = false
		timer.timeout.connect(func():
			countdown -= 1
			countdown_label.text = "%d..." % countdown
			if countdown <= 0:
				advance_tutorial()
		)
		add_child(timer)
		timer.start()

func _on_player_state_changed(state: Enums.PlayerState):
	if current_idx == 5 and state == Enums.PlayerState.RELOADING:
		advance_tutorial()
	
func _on_gun_state_changed(state: Enums.GunState):
	if current_idx == 6 and state == Enums.GunState.LOADED:
		advance_tutorial()
	elif current_idx == 7 and state == Enums.GunState.PRIMED:
		spawner_walking._on_spawn_timer_timeout()
		advance_tutorial()



func _on_tutorial_advanced(idx: int):
	for step in tut_steps.get_children():
		if step.get_index() == current_idx:
			step.show()
		else:
			step.hide()

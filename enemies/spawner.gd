extends Node3D

@export var enemy: PackedScene
@export var spawn_interval: float = 5.0
@export var checkpoint: int
@export var activate_tag: int

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = spawn_interval
	timer.autostart = false
	timer.stop()
	timer.timeout.connect(_on_spawn_timer_timeout)

	Signals.lamp_lit.connect(_checkpoint_reached)
	Signals.activate_spawners.connect(_activate_spawner)

func _activate_spawner(tag):
	if tag == activate_tag and timer.is_stopped():
		timer.start()

func _on_spawn_timer_timeout():
	if enemy:
		var instance = enemy.instantiate()
		add_child(instance)

func _checkpoint_reached(checkpoint_number):
	if checkpoint_number == checkpoint:
		timer.stop()

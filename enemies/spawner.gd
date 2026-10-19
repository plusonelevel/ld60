class_name Spawner extends Node3D

@export var enemy: PackedScene
@export var spawn_interval: float = 5.0
@export var checkpoint: int # ID of lamp that stops it
@export var activate_tag: int # ID of lamp that activates it

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_spawn_timer_timeout)

	Signals.lamp_lit.connect(_on_lamp_lit)

func _on_spawn_timer_timeout():
	if enemy:
		var instance = enemy.instantiate()
		add_child(instance)

func _on_lamp_lit(lamp_id):
	if lamp_id == activate_tag:
		timer.start()
	if lamp_id == checkpoint:
		timer.stop()

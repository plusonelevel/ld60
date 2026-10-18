extends Node3D


@export var enemy : PackedScene
@export var spawn_interval: float = 5.0
@export var checkpoint : int

func _ready():
	Signals.game_start.connect(_activate_spawner)
	Signals.lamp_lit.connect(_checkpoint_reached)

func _activate_spawner():
	_on_spawn_timer_timeout()
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", _on_spawn_timer_timeout)
	add_child(timer)

func _on_spawn_timer_timeout():
	if enemy:
		var instance = enemy.instantiate()
		add_child(instance)

func _checkpoint_reached(checkpoint_number):
	if checkpoint_number == checkpoint:
		queue_free()

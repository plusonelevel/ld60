extends Node3D


@export var enemy : PackedScene
@export var spawn_interval: float = 5.0
@export var checkpoint : int

@onready var timer: Timer = $Timer

func _ready():
	Signals.lamp_lit.connect(_checkpoint_reached)
	
	timer.wait_time = spawn_interval
	timer.connect("timeout", _on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	if enemy:
		var instance = enemy.instantiate()
		add_child(instance)

func _checkpoint_reached(checkpoint_number):
	if checkpoint_number == checkpoint:
		timer.stop()

extends Area3D


@export var enemy : PackedScene
@export var spawn_interval: float = 5.0

func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", _on_spawn_timer_timeout)
	add_child(timer)

func _on_spawn_timer_timeout():
	if enemy:
		var instance = enemy.instantiate()
		add_child(instance)

extends Control


@onready var status = $StatusMessage

var tween: Tween

func _ready() -> void:
	Signals.status_message.connect(_status_message_change)
	
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

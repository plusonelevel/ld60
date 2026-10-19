extends Label

func _ready() -> void:
	hide()
	Signals.aim_prompt_changed.connect(_on_prompt_changed)

func _on_prompt_changed(prompt: String) -> void:
	text = prompt
	visible = prompt != ""

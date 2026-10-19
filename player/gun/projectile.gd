class_name Projectile extends RigidBody3D

var is_primed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func grab():
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true

func release():
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = false

func prime():
	is_primed = true

func _on_body_entered(body: Node) -> void:
	print_debug("projectile hit %s" % body.name)
	if is_primed and body is Enemy:
		if body.has_method("take_dmg"):
			body.play_hit()
			body.take_dmg(20)
		queue_free()
	is_primed = false

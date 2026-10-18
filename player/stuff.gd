extends Node3D

var projectile_scn = preload("res://player/gun/projectile.tscn")

var RAYCAST_LENGTH = 0.3
var dragged: Variant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragged:
		dragged.position = _get_mouse_target(null)

func _get_mouse_target(mask: Variant):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()

	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAYCAST_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	if mask:
		query.collision_mask = mask
		var col = space_state.intersect_ray(query)
		if col.is_empty():
			return null
		else:
			return col.position
	else:
		return end

func handle_click() -> void:
	var target = _get_mouse_target(1024)
	if target:
		print_debug("click into clickable detected")
		var projectile: Projectile = projectile_scn.instantiate()
		projectile.scale = Vector3.ONE * 0.5
		projectile.position = target
		projectile.grab()
		get_tree().get_root().add_child(projectile)
		dragged = projectile
		
func handle_release():
	if dragged and dragged is Projectile:
		dragged.release()
		dragged = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and GameManager.player_state == Enums.PlayerState.RELOADING:
		if event.pressed:
			handle_click()
		else:
			handle_release()

func _on_barrel_body_entered(body: Node3D) -> void:
	if body is Projectile:
		body.queue_free()
		#Signals.gun_loaded.emit()
		Signals.gun_primed.emit()

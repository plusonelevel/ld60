extends Node3D

@onready var pouch := $Pouch
var pouch_orig_pos: Vector3

var projectile_scn = preload("res://player/gun/projectile.tscn")

var RAYCAST_LENGTH = 1.0
var dragged: Variant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.gun_loaded.connect(_on_gun_loaded)
	Signals.gun_primed.connect(_on_gun_primed)
	
	pouch_orig_pos = pouch.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragged:
		var target = _get_mouse_target(2048)
		if target.is_empty():
			dragged.release()
			dragged = null
		else:
			dragged.position = target.position

func _get_mouse_target(mask: int):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()

	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAYCAST_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = mask
	query.collide_with_areas = true
	return space_state.intersect_ray(query)
	
func handle_click() -> void:
	var target = _get_mouse_target(1024)
	if target.is_empty():
		return
	var collider = target.collider		
	if collider:
		if collider == pouch and GameManager.gun_state == Enums.GunState.DEFAULT:
			var projectile: Projectile = projectile_scn.instantiate()
			projectile.scale = Vector3.ONE * 0.5
			projectile.position = collider.position
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
		Signals.gun_loaded.emit()
		#Signals.gun_primed.emit()

func _on_gun_loaded():
	var tween = create_tween()
	tween.tween_property(pouch, ^"position", pouch_orig_pos + Vector3(0, 0, 1), GameManager.reload_transition_length)
	
func _on_gun_primed():
	var tween = create_tween()
	tween.tween_property(pouch, ^"position", pouch_orig_pos, GameManager.reload_transition_length)

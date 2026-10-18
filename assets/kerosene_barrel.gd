extends Node3D

@export var ray_length := 3.0


func _unhandled_input(event: InputEvent) -> void:
	var left_click: bool = event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT
	if not left_click:
		return

	var hit := _aim_target()
	if not (hit and (hit == self or is_ancestor_of(hit))):
		return

	get_viewport().set_input_as_handled()

	var player := get_tree().get_first_node_in_group("player") as Player
	if not player:
		return
	if not player.kerosene_shown:
		Signals.status_message.emit("You need a kerosene bottle in hand.")
	elif player.kerosene_amount >= Player.KEROSENE_CAPACITY:
		Signals.status_message.emit("The bottle is already full.")
	else:
		player.fill_kerosene()


func _aim_target() -> Node:
	var cam := get_viewport().get_camera_3d()
	if not cam:
		return null
	var centre := get_viewport().get_visible_rect().size / 2.0
	var from := cam.project_ray_origin(centre)
	var to := from + cam.project_ray_normal(centre) * ray_length
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	return get_world_3d().direct_space_state.intersect_ray(query).get("collider")

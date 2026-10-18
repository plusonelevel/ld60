extends Node3D

@export_group("Lamp pressure")
@export var fill_time := 5.0
@export var drain_time := 10.0

@onready var door: Area3D = $lamp_controls/Door
@onready var door2: Area3D = $lamp_controls/Door2
@onready var splash: Area3D = $lamp_controls/Splash
@onready var valve: Area3D = $lamp_controls/Valve
@onready var valve_pivot: Node3D = $lamp_controls/Valve/ValvePivot
@onready var piston_indicator: MeshInstance3D = $lamp_controls/PistonIndicator
@onready var ind1light = $lamp_controls/Indicator1/Indicator1Light
@onready var ind2light = $lamp_controls/Indicator2/Indicator2Light

signal pressure_full
signal pressure_empty

var door_open := false
var splash_slid := false
var splash_rest: Vector3
var splash_tween: Tween
var valve_spinning := false

var pressure := 0.0
var piston_rest: Vector3
var dry_spin_elapsed := 0.0

var door_key: Key = KEY_E
var splash_key: Key = KEY_G
var valve_key: Key = KEY_F
var ray_length := 3.0

var splash_offset := Vector3(0, 0, -0.02)
var splash_time := 0.25
var valve_axis := Vector3.RIGHT
var valve_speed := 180.0
var piston_travel := Vector3(0, 0.1, 0)
var dry_spin_time := 3.0

var draining := false


func _ready() -> void:
	splash_rest = splash.position
	piston_rest = piston_indicator.position
	_set_door(false)
	_update_piston()
	ind1light.hide()
	ind2light.show()


func _process(delta: float) -> void:
	if draining:
		pressure = maxf(pressure - delta / drain_time, 0.0)
		_update_piston()
		if pressure <= 0.0:
			draining = false
			pressure_empty.emit()
			ind1light.hide()
			ind2light.show()

	if not valve_spinning:
		return

	valve_pivot.rotate_object_local(valve_axis.normalized(), deg_to_rad(valve_speed) * delta)

	if splash_slid and not draining:
		pressure = minf(pressure + delta / fill_time, 1.0)
		_update_piston()
		if pressure >= 1.0:
			valve_spinning = false
			_toggle_splash()
			draining = true
			pressure_full.emit()
			ind1light.show()
			ind2light.hide()
	else:
		dry_spin_elapsed += delta
		if dry_spin_elapsed >= dry_spin_time:
			valve_spinning = false


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		door_key:
			var hit := _aim_target()
			if _is_part(door, hit) or _is_part(door2, hit):
				_set_door(not door_open)
		splash_key:
			if not draining and _is_part(splash, _aim_target()):
				_toggle_splash()
		valve_key:
			if not draining and _is_part(valve, _aim_target()):
				valve_spinning = not valve_spinning
				dry_spin_elapsed = 0.0


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


func _is_part(node: Node, hit: Node) -> bool:
	return hit != null and (hit == node or node.is_ancestor_of(hit))


func _set_door(open: bool) -> void:
	door_open = open
	_enable(door, not open)
	_enable(door2, open)


func _enable(node: Node3D, on: bool) -> void:
	node.visible = on
	node.process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED


func _toggle_splash() -> void:
	splash_slid = not splash_slid
	dry_spin_elapsed = 0.0
	var target := splash_rest + (splash.basis * splash_offset if splash_slid else Vector3.ZERO)
	if splash_tween:
		splash_tween.kill()
	splash_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	splash_tween.tween_property(splash, "position", target, splash_time)


func _update_piston() -> void:
	piston_indicator.position = piston_rest + piston_indicator.basis * piston_travel * pressure

extends Node3D

signal pressure_full
signal pressure_empty

@export_group("Lamp pressure")
@export var fill_time := 5.0
@export var drain_time := 10.0
@export var cone_presses_needed := 3
@export var cone_fill_time := 0.6

@onready var door: Area3D = $lamp_controls/Door
@onready var door_mesh: MeshInstance3D = $lamp_controls/Door/Door
@onready var door2: Area3D = $lamp_controls/Door2
@onready var splash: Area3D = $lamp_controls/Splash
@onready var valve: Area3D = $lamp_controls/Valve
@onready var valve_pivot: Node3D = $lamp_controls/Valve/ValvePivot
@onready var cone: Area3D = $lamp_controls/Cone
@onready var kerosene: MeshInstance3D = $lamp_controls/Kerosene
@onready var cone_sfx = $Cone
@onready var valve_sfx = $Valve
@onready var splash_sfx = $Splash
@onready var door_open_sfx = $DoorOpen
@onready var door_close_sfx = $DoorClose

var interact_key: Key = KEY_E
var ray_length := 3.0

var splash_offset := Vector3(0, 0, -0.02)
var splash_time := 0.25
var valve_axis := Vector3.RIGHT
var valve_speed := 180.0
var dry_spin_time := 3.0

const KEROSENE_FULL_POS := Vector3(0, 0, 0)
const KEROSENE_FULL_SCALE := Vector3(1, 0.95, 0.95)
const KEROSENE_EMPTY_POS := Vector3(0, 0.7, 0)
const KEROSENE_EMPTY_SCALE := Vector3(1, 0.045, 0.95)

var door_open := false
var splash_slid := false
var splash_rest: Vector3
var splash_tween: Tween
var valve_spinning := false
var dry_spin_elapsed := 0.0

var pressure := 0.0
var draining := false
var cone_presses := 0

var kerosene_level := 0.0:
	set(value):
		kerosene_level = value
		if kerosene:
			_update_kerosene()
var kerosene_tween: Tween


func _ready() -> void:
	splash_rest = splash.position
	_set_door(false, false)
	_update_kerosene()


func _process(delta: float) -> void:
	if draining:
		pressure = maxf(pressure - delta / drain_time, 0.0)
		kerosene_level = pressure
		if pressure <= 0.0:
			draining = false
			pressure_empty.emit()

	if not valve_spinning:
		return

	valve_pivot.rotate_object_local(valve_axis.normalized(), deg_to_rad(valve_speed) * delta)

	if _can_fill():
		pressure = minf(pressure + delta / fill_time, 1.0)
		if pressure >= 1.0:
			valve_spinning = false
			cone_presses = 0
			_toggle_splash()
			draining = true
			pressure_full.emit()
	else:
		dry_spin_elapsed += delta
		if dry_spin_elapsed >= dry_spin_time:
			valve_spinning = false


func _can_fill() -> bool:
	return splash_slid and not draining and cone_presses >= cone_presses_needed


func _unhandled_input(event: InputEvent) -> void:
	var e_pressed: bool = event is InputEventKey and event.pressed and not event.echo \
			and event.keycode == interact_key
	var left_click: bool = event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT

	if not (e_pressed or left_click):
		return

	var hit := _aim_target()

	if left_click:
		if not draining and _is_part(cone, hit):
			_pour_cone()
			get_viewport().set_input_as_handled()
		return

	#E
	if _is_part(door, hit) or _is_part(door2, hit):
		_set_door(not door_open)
	elif draining:
		return
	elif _is_part(splash, hit):
		_toggle_splash()
	elif _is_part(valve, hit):
		valve_spinning = not valve_spinning
		valve_sfx.play()
		dry_spin_elapsed = 0.0


func _pour_cone() -> void:
	if cone_presses >= cone_presses_needed:
		return

	var player := get_tree().get_first_node_in_group("player") as Player
	if not player or not player.kerosene_shown:
		Signals.status_message.emit("You need a kerosene bottle in hand.")
		return
	if player.kerosene_amount <= 0:
		Signals.status_message.emit("The bottle is empty. Fill it at the barrel.")
		return
	
	cone_sfx.play()
	player.kerosene_amount -= 1
	Signals.kerosene_amount_changed.emit(player.kerosene_amount)
	cone_presses += 1
	var target := float(cone_presses) / cone_presses_needed
	if kerosene_tween:
		kerosene_tween.kill()
	kerosene_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	kerosene_tween.tween_property(self, "kerosene_level", target, cone_fill_time)


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


func _set_door(open: bool, play_sound := true) -> void:
	door_open = open
	_enable(door, not open)
	_enable(door2, open)
	if play_sound:
		if open:
			door_open_sfx.play()
		else:
			door_close_sfx.play()
	Signals.lamp_door_opened.emit(door_open)


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
	splash_sfx.play()


func _update_kerosene() -> void:
	kerosene.position = KEROSENE_EMPTY_POS.lerp(KEROSENE_FULL_POS, kerosene_level)
	kerosene.scale = KEROSENE_EMPTY_SCALE.lerp(KEROSENE_FULL_SCALE, kerosene_level)

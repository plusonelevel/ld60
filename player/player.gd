class_name Player extends CharacterBody3D

@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA : Camera3D

@onready var stuff: Node3D = $Stuff
@onready var gun: Gun = $Gun
@onready var kerosene = $kerosene

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3

var kerosene_shown := false
var kerosene_rest:= Vector3(-0.153,-0.1,-0.163)
var kerosene_tween: Tween
var kerosene_amount = 0
const KEROSENE_CAPACITY := 5

var gun_rest: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and GameManager.player_state == Enums.PlayerState.DEFAULT
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
	elif event.is_action_pressed(&"reload") and not kerosene_shown \
			and (GameManager.player_state == Enums.PlayerState.DEFAULT or GameManager.player_state == Enums.PlayerState.RELOADING):
		toggle_reloading()
	elif event is InputEventMouseButton and event.pressed \
		and event.button_index == MOUSE_BUTTON_RIGHT \
		and GameManager.player_state == Enums.PlayerState.DEFAULT:
		toggle_kerosene()
		
func _update_camera(delta):
	
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(_mouse_rotation.x,_mouse_rotation.y,0.0)
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _ready():
	Signals.gun_primed.connect(_on_gun_primed)
	
	gun_rest = gun.position
	kerosene.position = kerosene_rest + Vector3(0, -0.3, 0)
	kerosene.hide()
	
	
	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	if not GameManager.player_state == Enums.PlayerState.DEFAULT:
		return

	# Update camera movement based on mouse movement
	_update_camera(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func toggle_reloading():
	var tween = create_tween().set_parallel()
	var needs_reloading = GameManager.player_state == Enums.PlayerState.DEFAULT and GameManager.gun_state != Enums.GunState.PRIMED
	if needs_reloading:
		Signals.player_state_changed.emit(Enums.PlayerState.RELOADING)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		tween.tween_property(CAMERA, ^"position", Vector3(0, -0.5, 0), GameManager.reload_transition_length)
		tween.tween_property(self, ^"rotation:x", 0.0, GameManager.reload_transition_length)
		tween.tween_property(CAMERA, ^"rotation:x", -PI/4, GameManager.reload_transition_length)
		gun.start_reloading()
	else:
		Signals.player_state_changed.emit(Enums.PlayerState.DEFAULT)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		tween.tween_property(CAMERA, ^"position", Vector3.ZERO, GameManager.reload_transition_length)
		tween.tween_property(CAMERA, ^"rotation:x", 0, GameManager.reload_transition_length)
		gun.stop_reloading()
		
		
func _on_gun_primed():
	if GameManager.player_state == Enums.PlayerState.RELOADING:
		toggle_reloading()

func toggle_kerosene():
	kerosene_shown = not kerosene_shown

	var out_item: Node3D = gun if kerosene_shown else kerosene
	var out_rest: Vector3 = gun_rest if kerosene_shown else kerosene_rest
	var in_item: Node3D = kerosene if kerosene_shown else gun
	var in_rest: Vector3 = kerosene_rest if kerosene_shown else gun_rest

	if kerosene_tween:
		kerosene_tween.kill()
	kerosene_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	
	kerosene_tween.tween_property(out_item, ^"position", out_rest + Vector3(0, -0.3, 0), 0.2)
	kerosene_tween.tween_callback(out_item.hide)

	kerosene_tween.tween_callback(in_item.show)
	kerosene_tween.tween_property(in_item, ^"position", in_rest, 0.2)

func fill_kerosene() -> void:
	kerosene_amount = KEROSENE_CAPACITY
	Signals.status_message.emit("Bottle filled.")

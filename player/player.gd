class_name Player extends CharacterBody3D

@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA : Camera3D

@onready var stuff: Node3D = $Stuff
@onready var gun: Node3D = $Gun

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3

var reload_transition := 0.1
var orig_gun_transform


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
	elif event.is_action_pressed(&"reload"):
		toggle_reloading()	
		
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
	orig_gun_transform = gun.transform
	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	
	# Update camera movement based on mouse movement
	if GameManager.player_state == Enums.PlayerState.DEFAULT:
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
	
	stuff.rotation.x = 0.0
	stuff.position.y = -0.2

func toggle_reloading():
	var tween = create_tween().set_parallel()
	if GameManager.player_state == Enums.PlayerState.DEFAULT and GameManager.gun_state != Enums.GunState.PRIMED:
		Signals.player_state_changed.emit(Enums.PlayerState.RELOADING)
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		tween.tween_property(CAMERA, ^"position", Vector3(0, -0.5, 0), reload_transition)
		tween.tween_property(self, ^"rotation:x", 0.0, reload_transition)
		tween.tween_property(CAMERA, ^"rotation:x", -PI/4, reload_transition)
		tween.tween_property(gun, ^"position", Vector3(0.4, -1.1, 0.2), reload_transition)
		tween.tween_property(gun, ^"rotation", Vector3(PI/4, PI/6, 0), reload_transition)
	else:
		Signals.player_state_changed.emit(Enums.PlayerState.DEFAULT)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		tween.tween_property(CAMERA, ^"position", Vector3.ZERO, reload_transition)
		tween.tween_property(CAMERA, ^"rotation:x", 0, reload_transition)
		tween.tween_property(gun, ^"transform", orig_gun_transform, reload_transition)
		
func _on_gun_primed():
	if GameManager.player_state == Enums.PlayerState.RELOADING:
		toggle_reloading()

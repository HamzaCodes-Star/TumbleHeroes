extends CharacterBody3D
class_name StumblePlayer

# --- Movement Parameters ---
@export var speed: float = 9.0
@export var acceleration: float = 60.0
@export var friction: float = 45.0
@export var jump_velocity: float = 9.5
@export var gravity: float = 24.0

# --- Stumble Guys Dive Mechanic ---
@export var dive_forward_force: float = 12.0
@export var dive_upward_force: float = 3.5
@export var dive_duration: float = 0.75

# --- State ---
var can_dive: bool = false
var is_diving: bool = false
var is_stumbled: bool = false
var dive_timer: float = 0.0
var spawn_point: Vector3 = Vector3.ZERO

const GameSettings = preload("res://scripts/game_settings.gd")

var sfx_boing: AudioStream = preload("res://assets/sounds/jump_boing.wav")
var sfx_whoosh: AudioStream = preload("res://assets/sounds/dive_whoosh.wav")
var sfx_bonk: AudioStream = preload("res://assets/sounds/stumble_bonk.wav")

@onready var visual_mesh: Node3D = $Visuals if has_node("Visuals") else $MeshInstance3D
@onready var spring_arm: SpringArm3D = $SpringArm3D

func _ready() -> void:
	add_to_group("racers")
	add_to_group("players")
	spawn_point = global_position
	if has_node("Visuals"):
		$Visuals.apply_skin(GameSettings.selected_skin_index)

func _play_sfx(stream: AudioStream, vol: float = -4.0) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = vol
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		can_dive = true # Reset dive whenever player touches the floor

	# 2. Handle Jump & Dive Inputs
	if Input.is_action_just_pressed("jump") and not is_stumbled:
		if is_on_floor():
			velocity.y = jump_velocity
			_play_sfx(sfx_boing, -3.0)
		elif can_dive and not is_diving:
			perform_dive()

	# 3. Handle Diving / Sliding State
	if is_diving or is_stumbled:
		dive_timer -= delta
		if dive_timer <= 0:
			recover_from_dive()
		
		# Floor friction while sliding
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * 0.4 * delta)
			velocity.z = move_toward(velocity.z, 0, friction * 0.4 * delta)
	else:
		# 4. Standard Running Movement
		handle_locomotion(delta)

	move_and_slide()

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_moving := horizontal_speed > 0.5 and is_on_floor()
	if has_node("Visuals"):
		$Visuals.update_animation(delta, is_moving, is_on_floor(), is_diving, is_stumbled)

func handle_locomotion(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Direction relative to camera view
	var cam_basis := spring_arm.global_transform.basis if spring_arm else global_transform.basis
	var forward := -cam_basis.z
	var right := cam_basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	var move_direction := (right * input_dir.x + forward * -input_dir.y).normalized()

	if move_direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, move_direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, move_direction.z * speed, acceleration * delta)
		
		# Rotate character mesh smoothly towards movement direction
		var target_angle := atan2(move_direction.x, move_direction.z)
		visual_mesh.rotation.y = lerp_angle(visual_mesh.rotation.y, target_angle, 15.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

func perform_dive() -> void:
	is_diving = true
	can_dive = false
	dive_timer = dive_duration
	_play_sfx(sfx_whoosh, -3.0)

	# Dive forward in mesh facing direction
	var forward := Vector3.FORWARD.rotated(Vector3.UP, visual_mesh.rotation.y)
	velocity.x = forward.x * dive_forward_force
	velocity.z = forward.z * dive_forward_force
	velocity.y = dive_upward_force

	# Tilt mesh flat horizontally (belly flop slide)
	visual_mesh.rotation.x = deg_to_rad(-85)

func recover_from_dive() -> void:
	is_diving = false
	is_stumbled = false
	visual_mesh.rotation.x = 0

# Called when hit by spinning hammer, bumper, or falling obstacle
func stumble(knockback: Vector3, duration: float = 1.0) -> void:
	is_stumbled = true
	dive_timer = duration
	velocity = knockback
	visual_mesh.rotation.x = deg_to_rad(-85)
	_play_sfx(sfx_bonk, -2.0)

# Respawn player at last checkpoint
func respawn() -> void:
	global_position = spawn_point
	velocity = Vector3.ZERO
	recover_from_dive()

# Mobile touch button trigger
func _on_jump_button_down() -> void:
	if not is_stumbled:
		if is_on_floor():
			velocity.y = jump_velocity
			_play_sfx(sfx_boing, -3.0)
		elif can_dive and not is_diving:
			perform_dive()


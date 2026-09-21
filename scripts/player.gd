extends CharacterBody3D
class_name StumblePlayer

# --- Movement Parameters ---
@export var speed: float = 9.0
@export var acceleration: float = 60.0
@export var friction: float = 45.0
@export var jump_velocity: float = 9.5
@export var gravity: float = 24.0

# --- Camera Sensitivity ---
@export var touch_sensitivity: float = 0.005
@export var gyro_sensitivity: float = 2.2

# --- Stumble Guys Dive Mechanic ---
@export var dive_forward_force: float = 12.0
@export var dive_upward_force: float = 3.5
@export var dive_duration: float = 0.75

# --- State ---
var can_dive: bool = false
var is_diving: bool = false
var is_stumbled: bool = false
var dive_timer: float = 0.0
var stumble_duration_total: float = 1.0
var spawn_point: Vector3 = Vector3.ZERO
var previous_fall_speed: float = 0.0

const GameSettings = preload("res://scripts/game_settings.gd")
const GM = preload("res://scripts/game_manager.gd")

var sfx_boing: AudioStream = preload("res://assets/sounds/jump_boing.wav")
var sfx_whoosh: AudioStream = preload("res://assets/sounds/dive_whoosh.wav")
var sfx_bonk: AudioStream = preload("res://assets/sounds/stumble_bonk.wav")

@onready var visual_mesh: Node3D = $Visuals if has_node("Visuals") else $MeshInstance3D
var controls: CanvasLayer
@onready var spring_arm: SpringArm3D = $SpringArm3D

func _ready() -> void:
	add_to_group("racers")
	add_to_group("players")
	spawn_point = global_position
	controls = get_tree().root.find_child("MobileHUD", true, false) as CanvasLayer
	if has_node("Visuals"):
		$Visuals.apply_skin(GameSettings.selected_skin_index)

func _play_sfx(stream: AudioStream, vol: float = -4.0) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = vol
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _unhandled_input(event: InputEvent) -> void:
	if not spring_arm:
		return
	if event is InputEventScreenDrag:
		var joy_idx: int = controls.joystick._touch_index if (controls and controls.get("joystick") and "_touch_index" in controls.joystick) else -1
		if event.index != joy_idx:
			spring_arm.rotation.y -= event.relative.x * touch_sensitivity
			spring_arm.rotation.x = clamp(spring_arm.rotation.x - event.relative.y * touch_sensitivity, deg_to_rad(-60), deg_to_rad(25))
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var joy_idx: int = controls.joystick._touch_index if (controls and controls.get("joystick") and "_touch_index" in controls.joystick) else -1
			if joy_idx != 999:
				spring_arm.rotation.y -= event.relative.x * touch_sensitivity
				spring_arm.rotation.x = clamp(spring_arm.rotation.x - event.relative.y * touch_sensitivity, deg_to_rad(-60), deg_to_rad(25))

func _physics_process(delta: float) -> void:
	# 1. Camera Look (Touch Screen Swipe & Hardware Gyroscope)
	handle_camera_look(delta)

	# 2. Apply Gravity & High Fall Ragdoll Check
	if not is_on_floor():
		velocity.y -= gravity * delta
		previous_fall_speed = -velocity.y
	else:
		can_dive = true
		# If landing after a high drop (> 14m/s), trigger brief landing stumble roll!
		if previous_fall_speed > 14.0 and not is_stumbled and not is_diving:
			stumble(velocity * 0.5 + Vector3.UP * 2.0, 0.7)
		previous_fall_speed = 0.0

	# 3. Handle Jump & Dive Inputs
	var touch_jump: bool = controls.get("jump_pressed") if (controls and "jump_pressed" in controls) else false
	var key_jump := Input.is_action_just_pressed("jump")
	if (touch_jump or key_jump) and not is_stumbled:
		if is_on_floor():
			velocity.y = jump_velocity
			_play_sfx(sfx_boing, -3.0)
			if controls: controls.set("jump_pressed", false)
		elif can_dive and not is_diving:
			perform_dive()
			if controls: controls.set("jump_pressed", false)

	# 4. Handle Diving / Sliding State
	if is_diving or is_stumbled:
		dive_timer -= delta
		if dive_timer <= 0:
			recover_from_dive()
		
		# Floor friction while sliding
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * 0.4 * delta)
			velocity.z = move_toward(velocity.z, 0, friction * 0.4 * delta)

		# If diving into a wall or obstacle -> BONK into full tumbling ragdoll!
		if is_diving and is_on_wall():
			is_diving = false
			var col := get_last_slide_collision()
			var wall_norm := col.get_normal() if col else -velocity.normalized()
			stumble(wall_norm * 6.5 + Vector3.UP * 4.5, 1.3)
	else:
		# 5. Standard Running Movement
		handle_locomotion(delta)

	move_and_slide()

	# 6. High-Speed Wall Impact Ragdoll Bonk
	if not is_stumbled and is_on_wall():
		var col := get_last_slide_collision()
		if col:
			var impact := -col.get_normal().dot(velocity)
			if impact > 5.5:
				var bounce_dir := col.get_normal() * 6.0 + Vector3.UP * 4.5
				stumble(bounce_dir, 1.2)

	# 7. Racer-to-Racer Physical Bumping
	var col_count := get_slide_collision_count()
	for i in range(col_count):
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider and collider != self and collider.is_in_group("racers"):
			var other_vel: Vector3 = collider.velocity if "velocity" in collider else Vector3.ZERO
			var relative_vel := velocity - other_vel
			if relative_vel.length() > 4.5 and not is_stumbled:
				if is_diving:
					if collider.has_method("stumble"):
						collider.stumble(-col.get_normal() * 7.5 + Vector3.UP * 4.0, 1.2)
				else:
					velocity += col.get_normal() * 3.5

	# 8. Visual Animations & Dynamic Ragdoll Update
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_moving := horizontal_speed > 0.5 and is_on_floor()
	if has_node("Visuals"):
		var stumble_prog := dive_timer / stumble_duration_total if stumble_duration_total > 0.0 else 0.0
		$Visuals.update_animation(delta, is_moving, is_on_floor(), is_diving, is_stumbled, stumble_prog, velocity)

func handle_camera_look(delta: float) -> void:
	if not spring_arm:
		return

	# 1. Screen Swipe Look (TouchControls buffer)
	if controls and "look_delta" in controls:
		var look: Vector2 = controls.get("look_delta")
		if look.length_squared() > 0.0:
			controls.set("look_delta", Vector2.ZERO)
			spring_arm.rotation.y -= look.x * touch_sensitivity
			spring_arm.rotation.x = clamp(spring_arm.rotation.x - look.y * touch_sensitivity, deg_to_rad(-60), deg_to_rad(25))

	# 2. Hardware Gyroscope (Device Tilt Orientation)
	var gyro := Input.get_gyroscope()
	if gyro.length() > 0.03:
		spring_arm.rotation.y -= gyro.y * gyro_sensitivity * delta
		spring_arm.rotation.x = clamp(spring_arm.rotation.x - gyro.x * gyro_sensitivity * delta, deg_to_rad(-60), deg_to_rad(25))

func handle_locomotion(delta: float) -> void:
	if not controls:
		controls = get_tree().root.find_child("MobileHUD", true, false) as CanvasLayer

	var touch_input: Vector2 = controls.get("move_vector") if (controls and "move_vector" in controls) else Vector2.ZERO
	var key_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir: Vector2 = touch_input if touch_input.length() > 0.01 else key_input

	if not GM.is_game_active:
		input_dir = Vector2.ZERO

	# Direction relative to camera view
	var cam_basis := spring_arm.global_transform.basis if spring_arm else global_transform.basis
	var forward := -cam_basis.z
	var right := cam_basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	var move_direction := (forward * -input_dir.y + right * input_dir.x)

	if move_direction.length() > 0.01:
		move_direction = move_direction.normalized()
		velocity.x = move_toward(velocity.x, move_direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, move_direction.z * speed, acceleration * delta)
		
		# Rotate character mesh smoothly towards movement direction (mesh front is -Z)
		var target_angle := atan2(-move_direction.x, -move_direction.z)
		visual_mesh.rotation.y = lerp_angle(visual_mesh.rotation.y, target_angle, 14.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

func perform_dive() -> void:
	is_diving = true
	can_dive = false
	dive_timer = dive_duration
	_play_sfx(sfx_whoosh, -3.0)

	# Forward in mesh facing direction (mesh front is -Z)
	var forward := Vector3.FORWARD.rotated(Vector3.UP, visual_mesh.rotation.y)
	velocity.x = forward.x * dive_forward_force
	velocity.z = forward.z * dive_forward_force
	velocity.y = dive_upward_force

func recover_from_dive() -> void:
	var was_stumbled := is_stumbled
	is_diving = false
	is_stumbled = false
	if was_stumbled and is_on_floor():
		velocity.y = 3.8
		_play_sfx(sfx_boing, -5.0)

func stumble(knockback: Vector3, duration: float = 1.2) -> void:
	is_stumbled = true
	stumble_duration_total = duration
	dive_timer = duration
	velocity = knockback
	_play_sfx(sfx_bonk, -2.0)

func respawn() -> void:
	global_position = spawn_point
	velocity = Vector3.ZERO
	recover_from_dive()

func _on_jump_button_down() -> void:
	if not is_stumbled:
		if is_on_floor():
			velocity.y = jump_velocity
			_play_sfx(sfx_boing, -3.0)
		elif can_dive and not is_diving:
			perform_dive()

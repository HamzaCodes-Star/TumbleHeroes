extends CharacterBody3D
class_name StumbleBot

const GM = preload("res://scripts/game_manager.gd")

@export var speed: float = 7.5
@export var acceleration: float = 40.0
@export var friction: float = 40.0
@export var jump_velocity: float = 9.0
@export var gravity: float = 24.0

var can_jump: bool = true
var is_stumbled: bool = false
var stumble_timer: float = 0.0
var target_z: float = -55.0 # Direction toward finish line
var lateral_target_x: float = 0.0
var jump_cooldown: float = 0.0
var spawn_point: Vector3

@onready var visual_mesh: Node3D = $Visuals if has_node("Visuals") else $MeshInstance3D

func _ready() -> void:
	add_to_group("racers")
	add_to_group("bots")
	spawn_point = global_position
	lateral_target_x = randf_range(-3.0, 3.0)
	if has_node("Visuals"):
		var random_skin = randi() % 6
		$Visuals.apply_skin(random_skin)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if is_stumbled:
		stumble_timer -= delta
		if stumble_timer <= 0:
			is_stumbled = false
			visual_mesh.rotation.x = 0
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			velocity.z = move_toward(velocity.z, 0, friction * delta)
		move_and_slide()
		return

	# Only move if match has started
	if not GM.is_game_active:
		return

	# Navigate toward Finish Line (Z: -55) with slight erratic human-like path
	var current_pos := global_position
	var target := Vector3(lateral_target_x, current_pos.y, target_z)
	var move_dir := (target - current_pos)
	move_dir.y = 0
	move_dir = move_dir.normalized()

	velocity.x = move_toward(velocity.x, move_dir.x * speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_dir.z * speed, acceleration * delta)

	if move_dir != Vector3.ZERO:
		visual_mesh.rotation.y = lerp_angle(visual_mesh.rotation.y, atan2(move_dir.x, move_dir.z), 10.0 * delta)

	# Random Bot Jumps / Obstacle Jump
	jump_cooldown -= delta
	if is_on_floor() and jump_cooldown <= 0:
		if randf() < 0.03 or (global_position.z > -35.0 and global_position.z < -15.0 and randf() < 0.08):
			velocity.y = jump_velocity
			jump_cooldown = randf_range(1.2, 3.0)
			# Occasionally change lateral target
			lateral_target_x = randf_range(-3.5, 3.5)

	move_and_slide()

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_moving := horizontal_speed > 0.5 and is_on_floor()
	if has_node("Visuals"):
		$Visuals.update_animation(delta, is_moving, is_on_floor(), false, is_stumbled)

func stumble(knockback: Vector3, duration: float = 1.0) -> void:
	is_stumbled = true
	stumble_timer = duration
	velocity = knockback
	visual_mesh.rotation.x = deg_to_rad(-85)

func respawn() -> void:
	global_position = spawn_point + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.0, 1.0))
	velocity = Vector3.ZERO
	is_stumbled = false
	visual_mesh.rotation.x = 0

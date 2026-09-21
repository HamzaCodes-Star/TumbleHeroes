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
var stumble_duration_total: float = 1.0
var target_z: float = -33.0
var lateral_target_x: float = 0.0
var jump_cooldown: float = 0.0
var spawn_point: Vector3

var waypoints: Array[Vector3] = [
	Vector3(0.0, -8.5, 20.0),
	Vector3(-2.0, -8.5, 5.0),
	Vector3(-7.0, -9.5, -10.0),
	Vector3(-10.0, -10.0, -22.0),
	Vector3(-13.0, -10.35, -33.0)
]
var current_wp_idx: int = 0

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
				velocity.y = 3.5
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			velocity.z = move_toward(velocity.z, 0, friction * delta)
		move_and_slide()
		var h_speed := Vector2(velocity.x, velocity.z).length()
		if has_node("Visuals"):
			var prog := stumble_timer / stumble_duration_total if stumble_duration_total > 0.0 else 0.0
			$Visuals.update_animation(delta, h_speed > 0.5, is_on_floor(), false, is_stumbled, prog, velocity)
		return

	# Only move if match has started
	if not GM.is_game_active:
		move_and_slide()
		return

	# Navigate along Meshy obstacle course waypoints toward finish line
	var current_pos := global_position
	var target_wp := waypoints[current_wp_idx] if current_wp_idx < waypoints.size() else Vector3(-13.0, -10.35, -33.0)
	var target := Vector3(target_wp.x + lateral_target_x, current_pos.y, target_wp.z)
	var dist_h := Vector2(current_pos.x - target.x, current_pos.z - target.z).length()
	if dist_h < 4.0 and current_wp_idx < waypoints.size() - 1:
		current_wp_idx += 1
		lateral_target_x = randf_range(-1.8, 1.8)
		target = Vector3(waypoints[current_wp_idx].x + lateral_target_x, current_pos.y, waypoints[current_wp_idx].z)

	var move_dir := (target - current_pos)
	move_dir.y = 0
	move_dir = move_dir.normalized()

	velocity.x = move_toward(velocity.x, move_dir.x * speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_dir.z * speed, acceleration * delta)

	if move_dir != Vector3.ZERO:
		visual_mesh.rotation.y = lerp_angle(visual_mesh.rotation.y, atan2(-move_dir.x, -move_dir.z), 10.0 * delta)

	# Random Bot Jumps
	jump_cooldown -= delta
	if is_on_floor() and jump_cooldown <= 0:
		if randf() < 0.03 or (global_position.z > -35.0 and global_position.z < -15.0 and randf() < 0.08):
			velocity.y = jump_velocity
			jump_cooldown = randf_range(1.2, 3.0)
			lateral_target_x = randf_range(-3.5, 3.5)

	move_and_slide()

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_moving := horizontal_speed > 0.5 and is_on_floor()
	if has_node("Visuals"):
		$Visuals.update_animation(delta, is_moving, is_on_floor(), false, is_stumbled)

func stumble(knockback: Vector3, duration: float = 1.2) -> void:
	is_stumbled = true
	stumble_duration_total = duration
	stumble_timer = duration
	velocity = knockback

func respawn() -> void:
	global_position = spawn_point + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.0, 1.0))
	velocity = Vector3.ZERO
	is_stumbled = false
	current_wp_idx = 0
	lateral_target_x = randf_range(-2.0, 2.0)
	visual_mesh.rotation.x = 0

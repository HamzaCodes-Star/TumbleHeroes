extends StaticBody3D
class_name TrapTile

@export var delay_before_fall: float = 0.4
@export var respawn_time: float = 3.0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var is_triggered: bool = false
var original_pos: Vector3

func _ready() -> void:
	original_pos = position

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not is_triggered and body.is_in_group("racers"):
		is_triggered = true
		_trigger_tile_fall()

func _trigger_tile_fall() -> void:
	# Shake effect
	var tween := create_tween()
	for i in range(4):
		tween.tween_property(mesh, "position:x", 0.08, 0.05)
		tween.tween_property(mesh, "position:x", -0.08, 0.05)
	tween.tween_property(mesh, "position:x", 0.0, 0.05)
	
	await get_tree().create_timer(delay_before_fall).timeout
	
	# Drop tile and disable collision
	collision_shape.set_deferred("disabled", true)
	var drop_tween := create_tween()
	drop_tween.tween_property(self, "position:y", original_pos.y - 10.0, 0.5)
	drop_tween.tween_property(self, "visible", false, 0.01)
	
	# Respawn tile after delay
	await get_tree().create_timer(respawn_time).timeout
	position = original_pos
	visible = true
	collision_shape.set_deferred("disabled", false)
	is_triggered = false

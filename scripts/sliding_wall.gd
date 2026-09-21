extends AnimatableBody3D
class_name SlidingWall

@export var move_distance: float = 4.0
@export var speed: float = 2.5
@export var knockback_power: float = 16.0

var start_x: float = 0.0
var time: float = 0.0

func _ready() -> void:
	start_x = position.x

func _physics_process(delta: float) -> void:
	time += delta * speed
	position.x = start_x + (sin(time) * move_distance)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("stumble"):
		var push_dir := Vector3(cos(time), 0.3, 0.5).normalized()
		body.stumble(push_dir * knockback_power, 1.0)

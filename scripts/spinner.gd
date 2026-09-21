extends AnimatableBody3D
class_name SpinnerObstacle

@export var rotation_speed: float = 2.5
@export var knockback_power: float = 18.0

func _physics_process(delta: float) -> void:
	# Spin continuously around Y axis
	rotate_y(rotation_speed * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("stumble"):
		# Calculate knockback vector outward from spinner center + upward lift
		var knock_dir := (body.global_position - global_position).normalized()
		knock_dir.y = 0.4
		body.stumble(knock_dir.normalized() * knockback_power, 1.2)

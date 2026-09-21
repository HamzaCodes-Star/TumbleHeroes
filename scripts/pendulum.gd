extends AnimatableBody3D
class_name PendulumObstacle

@export var swing_speed: float = 3.0
@export var max_angle_deg: float = 65.0
@export var knockback_power: float = 20.0

var time: float = 0.0

func _physics_process(delta: float) -> void:
	time += delta * swing_speed
	var current_angle = sin(time) * deg_to_rad(max_angle_deg)
	rotation.z = current_angle

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("stumble"):
		# Calculate knock direction based on pendulum velocity
		var swing_dir := Vector3.RIGHT if cos(time) > 0 else Vector3.LEFT
		swing_dir.y = 0.4
		body.stumble(swing_dir.normalized() * knockback_power, 1.2)

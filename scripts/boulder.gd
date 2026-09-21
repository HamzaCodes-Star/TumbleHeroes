extends AnimatableBody3D
class_name LavaBoulder

@export var roll_speed: float = 6.0
@export var knockback_power: float = 24.0
@export var reset_z: float = -5.0
@export var respawn_z: float = -45.0

func _physics_process(delta: float) -> void:
	# Roll forward along Z axis
	position.z += roll_speed * delta
	rotate_x(roll_speed * 1.5 * delta)
	
	if position.z > reset_z:
		position.z = respawn_z

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("stumble"):
		var knock_dir := Vector3(randf_range(-0.5, 0.5), 0.5, 1.0).normalized()
		body.stumble(knock_dir * knockback_power, 1.4)

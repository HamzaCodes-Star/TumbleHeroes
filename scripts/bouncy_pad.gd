extends Area3D
class_name BouncyPad

@export var bounce_force: float = 22.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("racers"):
		# Propel racer straight up into the air
		body.velocity.y = bounce_force
		if "can_dive" in body:
			body.can_dive = true

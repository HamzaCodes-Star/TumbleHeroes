extends Area3D
class_name KillPlane

func _ready() -> void:
	# Layer 1 = World/Props, Layer 2 = Racers (Player + Bots)
	collision_mask = 3
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		var GM = preload("res://scripts/game_manager.gd")
		if GM.instance and GM.is_game_active:
			GM.instance.end_round(false)
	elif body.has_method("respawn"):
		body.respawn()

extends Area3D
class_name FinishLine

const GM = preload("res://scripts/game_manager.gd")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("racers"):
		if GM.instance:
			GM.instance.register_qualification(body)

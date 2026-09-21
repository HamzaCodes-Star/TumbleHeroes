extends CanvasLayer
class_name GameHUD

const GM = preload("res://scripts/game_manager.gd")
var fanfare_sound: AudioStream = preload("res://assets/sounds/victory_fanfare.wav")
var bonk_sound: AudioStream = preload("res://assets/sounds/stumble_bonk.wav")

@onready var countdown_label: Label = $CountdownLabel
@onready var qualified_label: Label = $TopBar/QualifiedLabel
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var result_panel: Panel = $ResultPanel
@onready var result_title: Label = $ResultPanel/ResultTitle
@onready var restart_button: Button = $ResultPanel/RestartButton

var menu_button: Button

func _ready() -> void:
	result_panel.visible = false
	if GM.instance:
		GM.instance.qualification_updated.connect(_on_qualification_updated)
		GM.instance.match_ended.connect(_on_match_ended)
		GM.instance.match_started.connect(_on_match_started)

	# Dynamically add Menu Button if not already in scene
	if not result_panel.has_node("MenuButton"):
		menu_button = Button.new()
		menu_button.name = "MenuButton"
		menu_button.text = "MAIN MENU"
		menu_button.custom_minimum_size = Vector2(160, 48)
		menu_button.anchors_preset = Control.PRESET_CENTER_BOTTOM
		menu_button.position = Vector2(result_panel.size.x * 0.5 - 80, result_panel.size.y - 70)
		menu_button.pressed.connect(_on_menu_button_pressed)
		result_panel.add_child(menu_button)
		
		# Move restart button slightly up
		if restart_button:
			restart_button.position.y = result_panel.size.y - 130
		
	_play_countdown()

func _play_countdown() -> void:
	countdown_label.visible = true
	var steps = ["3", "2", "1", "STUMBLE! 🏃💨"]
	for text in steps:
		countdown_label.text = text
		countdown_label.scale = Vector2(1.6, 1.6)
		countdown_label.pivot_offset = countdown_label.size / 2.0
		var tween := create_tween()
		tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.7).timeout
	countdown_label.visible = false

func _process(_delta: float) -> void:
	if GM.is_game_active:
		var mins := int(GM.time_left) / 60
		var secs := int(GM.time_left) % 60
		timer_label.text = "%02d:%02d" % [mins, secs]

func _on_match_started() -> void:
	countdown_label.visible = false

func _on_qualification_updated(current: int, max_qual: int) -> void:
	qualified_label.text = "QUALIFIED: %d / %d" % [current, max_qual]
	var tw := create_tween()
	tw.tween_property(qualified_label, "scale", Vector2(1.2, 1.2), 0.15)
	tw.tween_property(qualified_label, "scale", Vector2(1.0, 1.0), 0.15)

func _on_match_ended(player_won: bool) -> void:
	result_panel.visible = true
	result_panel.scale = Vector2(0.8, 0.8)
	result_panel.pivot_offset = result_panel.size / 2.0
	var tw := create_tween()
	tw.tween_property(result_panel, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var p := AudioStreamPlayer.new()
	if player_won:
		result_title.text = "QUALIFIED! 🎉"
		result_title.modulate = Color(0.2, 1.0, 0.4)
		p.stream = fanfare_sound
		p.volume_db = -3.0
	else:
		result_title.text = "ELIMINATED! 💥"
		result_title.modulate = Color(1.0, 0.35, 0.35)
		p.stream = bonk_sound
		p.volume_db = -2.0

	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

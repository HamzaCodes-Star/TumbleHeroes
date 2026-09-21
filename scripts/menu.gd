extends Control

const GameSettings = preload("res://scripts/game_settings.gd")

@onready var skin_name_label: Label = $RightPanel/VBox/SkinPicker/SkinNameBox/SkinNameLabel
@onready var level_button_sky: Button = $RightPanel/VBox/LevelSelector/SkyButton
@onready var level_button_volcano: Button = $RightPanel/VBox/LevelSelector/VolcanoButton
@onready var level_button_ice: Button = $RightPanel/VBox/LevelSelector/IceButton
@onready var character_preview: Node3D = $CharacterStage/SubViewport/World3D/CharacterPreview
@onready var play_button: Button = $RightPanel/VBox/PlayButton

var boing_sfx: AudioStream = preload("res://assets/sounds/jump_boing.wav")
var current_skin_idx: int = 0
var current_level_path: String = "res://scenes/main.tscn"

func _ready() -> void:
	current_skin_idx = GameSettings.selected_skin_index
	current_level_path = GameSettings.selected_level_path
	_update_skin_ui(false)
	_highlight_selected_level()
	_animate_play_button()

func _process(delta: float) -> void:
	if character_preview:
		character_preview.update_animation(delta, false, true, false, false)

func _animate_play_button() -> void:
	if play_button:
		play_button.pivot_offset = play_button.size / 2.0
		var tw := create_tween().set_loops()
		tw.tween_property(play_button, "scale", Vector2(1.04, 1.04), 0.7).set_trans(Tween.TRANS_SINE)
		tw.tween_property(play_button, "scale", Vector2(1.0, 1.0), 0.7).set_trans(Tween.TRANS_SINE)

func _play_sfx(stream: AudioStream) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = -4.0
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _update_skin_ui(animate: bool = true) -> void:
	if skin_name_label:
		skin_name_label.text = GameSettings.SKIN_NAMES[current_skin_idx]
	GameSettings.selected_skin_index = current_skin_idx

	if character_preview:
		character_preview.apply_skin(current_skin_idx)
		if animate:
			_play_sfx(boing_sfx)
			var tw := create_tween()
			tw.tween_property(character_preview, "rotation:y", character_preview.rotation.y + TAU, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(character_preview, "position:y", 0.35, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.chain().tween_property(character_preview, "position:y", 0.05, 0.23).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_prev_color_pressed() -> void:
	current_skin_idx = (current_skin_idx - 1 + GameSettings.SKIN_NAMES.size()) % GameSettings.SKIN_NAMES.size()
	_update_skin_ui(true)

func _on_next_color_pressed() -> void:
	current_skin_idx = (current_skin_idx + 1) % GameSettings.SKIN_NAMES.size()
	_update_skin_ui(true)

func _on_sky_button_pressed() -> void:
	current_level_path = GameSettings.LEVEL_SKY
	_highlight_selected_level()

func _on_volcano_button_pressed() -> void:
	current_level_path = GameSettings.LEVEL_VOLCANO
	_highlight_selected_level()

func _on_ice_button_pressed() -> void:
	current_level_path = GameSettings.LEVEL_ICE
	_highlight_selected_level()

func _highlight_selected_level() -> void:
	GameSettings.selected_level_path = current_level_path
	_style_level_button(level_button_sky, current_level_path == GameSettings.LEVEL_SKY, Color(0.2, 0.8, 1.0))
	_style_level_button(level_button_volcano, current_level_path == GameSettings.LEVEL_VOLCANO, Color(1.0, 0.45, 0.2))
	_style_level_button(level_button_ice, current_level_path == GameSettings.LEVEL_ICE, Color(0.4, 0.95, 0.85))

func _style_level_button(btn: Button, selected: bool, active_color: Color) -> void:
	if not btn: return
	if selected:
		btn.modulate = Color(1.2, 1.2, 1.2)
		btn.self_modulate = active_color
	else:
		btn.modulate = Color(0.7, 0.7, 0.7)
		btn.self_modulate = Color(1, 1, 1)

func _on_play_button_pressed() -> void:
	_play_sfx(boing_sfx)
	get_tree().change_scene_to_file(current_level_path)

extends Control
class_name TouchScreenJoystick

@export var max_radius: float = 75.0
@export var deadzone: float = 10.0

var touch_index: int = -1
var stick_center: Vector2 = Vector2.ZERO
var current_output: Vector2 = Vector2.ZERO

@onready var tip: Control = $Tip
@onready var base: Control = $Base

func _ready() -> void:
	stick_center = Vector2.ZERO
	# Hide legacy square ColorRects and use smooth custom 2D canvas drawing
	if base:
		base.visible = false
	if tip:
		tip.visible = false
	queue_redraw()

func _draw() -> void:
	# 1. Outer joystick ring with soft dark glow
	draw_circle(stick_center, max_radius + 4.0, Color(0.04, 0.08, 0.16, 0.4))
	draw_circle(stick_center, max_radius, Color(0.12, 0.22, 0.38, 0.55))
	draw_arc(stick_center, max_radius, 0, TAU, 48, Color(0.35, 0.75, 1.0, 0.75), 3.0)

	# 2. Subtle directional guide markers
	for angle in [0, PI * 0.5, PI, PI * 1.5]:
		var dir = Vector2(cos(angle), sin(angle))
		draw_line(stick_center + dir * (max_radius - 12.0), stick_center + dir * (max_radius - 4.0), Color(1, 1, 1, 0.4), 2.0)

	# 3. Inner thumb knob
	var knob_pos = stick_center + current_output * max_radius
	draw_circle(knob_pos, 32.0, Color(0.05, 0.1, 0.2, 0.4)) # Knob drop shadow
	draw_circle(knob_pos, 30.0, Color(0.2, 0.65, 0.98, 0.9)) # Cyan knob
	draw_circle(knob_pos, 20.0, Color(0.85, 0.95, 1.0, 0.85)) # Inner gloss
	draw_arc(knob_pos, 30.0, 0, TAU, 32, Color(1, 1, 1, 0.95), 2.5)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			var touch_pos = event.position - global_position
			if touch_pos.distance_to(stick_center) <= max_radius * 1.8:
				touch_index = event.index
				_update_stick(touch_pos)
		elif not event.pressed and event.index == touch_index:
			_reset_stick()
			
	elif event is InputEventScreenDrag and event.index == touch_index:
		var touch_pos = event.position - global_position
		_update_stick(touch_pos)
		
	# Mouse fallback for testing in desktop editor
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = event.position - global_position
				if mouse_pos.distance_to(stick_center) <= max_radius * 1.8:
					touch_index = 999
					_update_stick(mouse_pos)
			else:
				if touch_index == 999:
					_reset_stick()
					
	elif event is InputEventMouseMotion and touch_index == 999:
		var mouse_pos = event.position - global_position
		_update_stick(mouse_pos)

func _update_stick(pos: Vector2) -> void:
	var offset: Vector2 = pos - stick_center
	var distance: float = offset.length()
	
	if distance > max_radius:
		offset = offset.normalized() * max_radius
		
	if distance > deadzone:
		current_output = offset / max_radius
	else:
		current_output = Vector2.ZERO
		
	queue_redraw()
	_emit_input_actions()

func _reset_stick() -> void:
	touch_index = -1
	current_output = Vector2.ZERO
	queue_redraw()
	_emit_input_actions()

func _emit_input_actions() -> void:
	# Convert stick vector to Godot Input actions
	Input.action_press("move_right", max(0.0, current_output.x))
	Input.action_press("move_left", max(0.0, -current_output.x))
	Input.action_press("move_back", max(0.0, current_output.y))
	Input.action_press("move_forward", max(0.0, -current_output.y))

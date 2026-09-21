extends Control
class_name TouchVirtualJoystick

## Bottom-left virtual joystick for movement input.
## Drag anywhere inside the base to get a direction; snaps back to center on release.
## Attach to a Control with two children: Base (outer circle) and Base/Knob (inner circle).

@export var joystick_radius: float = 80.0
@onready var base: Control = $Base
@onready var knob: Control = $Base/Knob if has_node("Base/Knob") else ($Tip if has_node("Tip") else $Base)

var _touch_index: int = -1
var output := Vector2.ZERO  # normalized direction, magnitude 0-1

func _ready() -> void:
	if base and knob:
		knob.position = base.size / 2 - knob.size / 2

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_reset_knob()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_knob(event.position)
	# Desktop mouse support for editor testing
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _touch_index == -1:
				_touch_index = 999
				_update_knob(event.position)
			elif not event.pressed and _touch_index == 999:
				_touch_index = -1
				_reset_knob()
	elif event is InputEventMouseMotion and _touch_index == 999:
		_update_knob(event.position)

func _update_knob(local_pos: Vector2) -> void:
	if not base or not knob:
		return
	var center := base.size / 2
	var offset := local_pos - center
	var clamped := offset.limit_length(joystick_radius)
	knob.position = center + clamped - knob.size / 2
	output = clamped / joystick_radius

func _reset_knob() -> void:
	if base and knob:
		knob.position = base.size / 2 - knob.size / 2
	output = Vector2.ZERO

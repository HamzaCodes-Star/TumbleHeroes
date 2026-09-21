extends CanvasLayer
class_name TouchControls

@onready var joystick: Control = $TouchJoystick if has_node("TouchJoystick") else ($VirtualJoystick if has_node("VirtualJoystick") else null)
@onready var jump_button: Button = $JumpButton

var _move_vector: Vector2 = Vector2.ZERO
var move_vector: Vector2:
	get:
		if joystick and "output" in joystick:
			return joystick.output
		return _move_vector
	set(val):
		_move_vector = val

var jump_pressed: bool = false
var look_delta: Vector2 = Vector2.ZERO

func _ready() -> void:
	if jump_button:
		jump_button.button_down.connect(func(): jump_pressed = true)
		jump_button.button_up.connect(func(): jump_pressed = false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var joy_idx: int = joystick._touch_index if (joystick and "_touch_index" in joystick) else -1
		if event.index != joy_idx:
			look_delta += event.relative
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var joy_idx: int = joystick._touch_index if (joystick and "_touch_index" in joystick) else -1
			if joy_idx != 999:
				look_delta += event.relative

func _process(_delta: float) -> void:
	pass

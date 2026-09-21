extends CanvasLayer
class_name TouchControls

const TouchVirtualJoystick = preload("res://scripts/virtual_joystick.gd")

## The UI overlay: wraps the joystick + jump button into one place the
## player script reads from. Attach to the CanvasLayer that contains
## VirtualJoystick (bottom-left) and a Button named JumpButton (bottom-right).

@onready var joystick: TouchVirtualJoystick = $TouchJoystick if has_node("TouchJoystick") else ($VirtualJoystick if has_node("VirtualJoystick") else null)
@onready var jump_button: Button = $JumpButton

var move_vector: Vector2 = Vector2.ZERO
var jump_pressed: bool = false

func _ready() -> void:
	if jump_button:
		jump_button.button_down.connect(func(): jump_pressed = true)
		jump_button.button_up.connect(func(): jump_pressed = false)

func _process(_delta: float) -> void:
	if joystick:
		move_vector = joystick.output

extends Node
class_name GameManager

signal match_started
signal match_ended(won: bool)
signal qualification_updated(current: int, max_qual: int)

@export var max_qual: int = 4
@export var round_time: float = 90.0

static var is_game_active: bool = false
static var time_left: float = 90.0
static var qualified_count: int = 0
static var instance: GameManager = null

var qualified_racers: Array = []

func _enter_tree() -> void:
	instance = self
	is_game_active = false
	time_left = round_time
	qualified_count = 0

func _ready() -> void:
	start_countdown()

func start_countdown() -> void:
	is_game_active = false
	await get_tree().create_timer(3.0).timeout
	is_game_active = true
	emit_signal("match_started")

func _process(delta: float) -> void:
	if not is_game_active:
		return
		
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		end_round(false)

func register_qualification(racer: Node) -> bool:
	if racer in qualified_racers:
		return false
		
	qualified_count += 1
	qualified_racers.append(racer)
	emit_signal("qualification_updated", qualified_count, max_qual)
	
	if racer.is_in_group("players"):
		end_round(true)
		return true
		
	if qualified_count >= max_qual:
		end_round(false)
		
	return true

func end_round(player_won: bool) -> void:
	if not is_game_active:
		return
	is_game_active = false
	emit_signal("match_ended", player_won)

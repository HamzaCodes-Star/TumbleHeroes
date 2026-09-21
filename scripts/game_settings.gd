extends Node

# Persistent user selection across scenes
static var selected_skin_index: int = 0
static var selected_level_path: String = "res://scenes/main.tscn"

const LEVEL_SKY = "res://scenes/main.tscn"
const LEVEL_VOLCANO = "res://scenes/level_volcano.tscn"
const LEVEL_ICE = "res://scenes/level_ice.tscn"

const SKIN_NAMES = [
	"Fluffy Teddy 🧸",
	"Goofy Penguin 🐧",
	"Chubby Rex 🦖",
	"King Fluff 👑",
	"Bouncy Cosmo 🚀",
	"Candy Bean 🍬"
]

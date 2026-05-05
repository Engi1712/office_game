extends Node

signal on_translation_updated

var is_debug: bool
var debug_options: DebugOptions
var current_scale: int
var resolution: Vector2
var current_level: String
var default_font: String

func _init():
	resolution = Vector2(640, 360)
	is_debug = false
	debug_options = DebugOptions.new()

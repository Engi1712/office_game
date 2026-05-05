extends Node

func _ready():
	Glob.is_debug = true
	Glob.debug_options.cur_part = DebugOptions.parts.BATTLE
	Glob.debug_options.battle_jump_in_place = DebugOptions.battle_jump_in.HOT_SEAT
	Glob.resolution = Vector2(640, 360)
	Glob.default_font = "res://Assests/LanaPixel.ttf"
	MenuSwitcher.switch("main_menu", {"initial": true})

extends Node2D

@onready var camera = $Anchor
@onready var player = $Player
@onready var map_sheet = $VirtMap

var current_pos = Vector2(0, 0)
var pos_offset = Vector2(0, 0)

func set_map(pos: Vector2):
	map_sheet.texture = load("res://Art/Office Pack/HUD/Minimaps/" + Glob.current_level + "_virt.png")
	match Glob.current_level:
		"room_008":
			pos_offset = Vector2(35, 15)
		"room_016":
			pos_offset = Vector2(57, 15)
	pos_offset *= 32
	pos += pos_offset
	current_pos = convert_to_tiles(pos)
	player.position = convert_to_pixels(current_pos)
	camera.position = convert_to_pixels(current_pos)

func move_map(pos: Vector2):
	pos += pos_offset
	var player_pos = convert_to_tiles(pos)
	var target = convert_to_pixels(player_pos)
	camera.move(target)
	player.position = target
	current_pos = player_pos

func convert_to_tiles(pos: Vector2):
	return (pos / 32).floor()

func convert_to_pixels(pos: Vector2):
	return (pos * 5)

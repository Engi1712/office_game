extends SubViewport

@onready var camera = $Anchor
@onready var player = $Player

var current_pos = Vector2(0, 0)

func set_map(position: Vector2):
	current_pos = convert_to_tiles(position)
	player.position = convert_to_pixels(current_pos)
	camera.position = convert_to_pixels(current_pos)

func move_map(position: Vector2):
	var player_pos = convert_to_tiles(position)
	var target = convert_to_pixels(player_pos)
	camera.move(target)
	player.position = target
	current_pos = player_pos

func convert_to_tiles(position: Vector2):
	return (position / 32).floor()

func convert_to_pixels(position: Vector2):
	return (position * 5) + Vector2(48, 48)

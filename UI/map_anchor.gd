extends Marker2D

func my_lerp(a: float, b: float, t: float):
	var diff = (b - a) * t
	print("Diff: " + str(diff))
	return a + diff

func move(player_pos: Vector2):
	var target_x = int(round(my_lerp(global_position.x, player_pos.x, 0.02)))
	var target_y = int(round(my_lerp(global_position.y, player_pos.y, 0.02)))
	global_position = Vector2(target_x, target_y)
	print("Player: " + str(player_pos))
	print("Camera: " + str(global_position))
	print("\n")

extends Marker2D

@onready var player = $"../Player"
@onready var camera = $"Camera"

func _process(_delta):
	if camera.enabled:
		var target = player.global_position
		var target_x = int(lerp(global_position.x, target.x, 0.2))
		var target_y = int(lerp(global_position.y, target.y, 0.2))
		global_position = Vector2(target_x, target_y)
	elif player.cam_ready:
		global_position = player.global_position
		camera.enabled = true

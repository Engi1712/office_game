extends Marker2D

@onready var player = $"../Player"
@onready var camera = $"Camera"
@onready var actual_cam_pos = global_position

func _process(delta):
	if camera.enabled:
		actual_cam_pos = lerp(player.global_position, actual_cam_pos, 0.2 * delta)
		global_position = actual_cam_pos
	elif player.spawned:
		actual_cam_pos = player.global_position
		global_position = player.global_position
		camera.enabled = true

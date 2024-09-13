extends RichTextLabel

@export var max_width:float = 500.0


var strings = ["hi", "hello!", "Hello there handsome!", "Lorem [b]ipsum[/b] dolor sit amet, [font_size=16]consectetur adipiscing elit.[/font_size] Ut faucibus consectetur sapien sed malesuada. Sed pellentesque tempus consequat. Aliquam ac facilisis sem. In convallis, quam quis interdum eleifend, lectus nibh mattis enim, ac iaculis sapien magna in ligula. Praesent sit amet aliquet erat, ac tempor sem. Sed sollicitudin enim vitae sem aliquam, a semper ante sodales. Vestibulum luctus venenatis velit in auctor. Nunc luctus mollis lacus. Morbi viverra congue diam, nec dapibus velit elementum at. In accumsan hendrerit diam. Integer feugiat laoreet cursus. Phasellus laoreet ipsum a laoreet viverra. Aliquam posuere enim dolor, sit amet pulvinar diam gravida ac. Maecenas cursus ultrices nunc eu semper."]


func _ready() -> void:
	size = Vector2.ZERO
	fit_content = true
	finished.connect(_fit_width, CONNECT_DEFERRED)
	text = strings[0]
	await get_tree().create_timer(3).timeout
	text = strings[1]
	await get_tree().create_timer(3).timeout
	text = strings[2]
	await get_tree().create_timer(3).timeout
	text = strings[3]


func _fit_width() -> void:
	set_block_signals(true)
	var original_autowrap = autowrap_mode
	var tmp = global_position
	global_position.x = -100000
	autowrap_mode = TextServer.AUTOWRAP_OFF
	size = Vector2.ZERO
	await get_tree().process_frame
	var w = clampf(size.x, 0, max_width)
	var h = size.y
	autowrap_mode = original_autowrap
	size.x = w
	await get_tree().process_frame
	if size.y > h:
		h = size.y
		while true:
			size.x -= 10
			await get_tree().process_frame
			if not is_equal_approx(size.y, h):
				size.x += 10
				break
	await get_tree().process_frame
	size.y = h
	global_position = tmp
	set_block_signals(false)

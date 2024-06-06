extends Camera2D

func _process(delta):
	move_to_mouse()

func move_to_mouse():
	var mousePos = get_global_mouse_position()
	position.x = (mousePos.x - global_position.x) / (1280.0 / 128)
	position.y = (mousePos.y - global_position.y) / (720.0 / 128)


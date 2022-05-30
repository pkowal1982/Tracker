extends TextureRect

signal color_chosen(color: Color)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("color_chosen", texture.get_image().get_pixelv(event.position))

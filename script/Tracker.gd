extends Control

const SIZE := Vector2(640, 480)

var selected_image: Image


func _ready() -> void:
	var button_group := ButtonGroup.new()
	$Gui/HsvTrack.set_pressed(true)
	$Gui/HsvTrack.button_group = button_group
	$Gui/HsvMask.button_group = button_group
	$Gui/MarkerTrack.button_group = button_group
	$Gui/Open.pressed.connect(on_open_pressed)
	$Gui/ColorPicker.get_picker().color_changed.connect(on_color_changed)
	$FileDialog.file_selected.connect(on_file_selected)
	$Gui/HsvTrack.pressed.connect(on_method_changed)
	$Gui/HsvMask.pressed.connect(on_method_changed)
	$Gui/MarkerTrack.pressed.connect(on_method_changed)
	$Gui/Hsv/H.value_changed.connect(on_threshold_changed)
	$Gui/Hsv/S.value_changed.connect(on_threshold_changed)
	$Gui/Hsv/V.value_changed.connect(on_threshold_changed)
	$Image.color_chosen.connect(on_color_chosen)
	get_viewport().size_changed.connect(on_size_changed)
	on_size_changed()
	selected_image = $Image.texture.get_image()
	track_image(selected_image)


func on_open_pressed() -> void:
	$Gui/Open/Arrow.hide()
	$FileDialog.show()
	$FileDialog.invalidate()


func on_size_changed() -> void:
	$FileDialog.min_size = get_viewport_rect().size
	$FileDialog.max_size = get_viewport_rect().size


func on_file_selected(path: String) -> void:
	var image := Image.new()
	var texture := ImageTexture.new()
	image.load(path)
	var image_size := image.get_size()
	var x_scale: float = image_size.x / SIZE.x
	var y_scale: float = image_size.y / SIZE.y
	var image_scale: float = max(x_scale, y_scale)
	if image_scale > 1.0:
		image_size /= image_scale
		image.resize(int(image_size.x), int(image_size.y))
	texture.create_from_image(image)
	$Image.size = image_size
	$Image.texture = texture
	selected_image = image
	track_image(image)


func on_method_changed() -> void:
	if not $Gui/HsvMask.button_pressed:
		$MaskedImage.texture = null
	track_image(selected_image)


func on_threshold_changed(_value: float) -> void:
	if not $Gui/MarkerTrack.button_pressed:
		track_image(selected_image)


func on_color_changed(_color: Color) -> void:
	if not $Gui/MarkerTrack.button_pressed:
		track_image(selected_image)


func on_color_chosen(color: Color) -> void:
	$Gui/ColorPicker.color = color
	if not $Gui/MarkerTrack.button_pressed:
		track_image(selected_image)


func track_image(image: Image) -> void:
	if image == null:
		return
	var result: Vector3
	if $Gui/HsvTrack.button_pressed:
		result = hsv_track(image, null)
	elif $Gui/HsvMask.button_pressed:
		result = hsv_track(image, Image.new())
	else:
		result = marker_track(image)
	$Cross.position = Vector2(result.x, result.y)
	$Cross.visible = result.z > 0
	if result.z < 0:
		$Margin/Status.text = "match not found"
	else:
		$Margin/Status.text = "match at (%.1f, %.1f), estimated diameter: %.1f" % [result.x, result.y, result.z]


func hsv_track(image: Image, masked_image: Image) -> Vector3:
	var tracker := HsvTracker.new()
	var color: Color = $Gui/ColorPicker.color
	var threshold := Vector3($Gui/Hsv/H.value, $Gui/Hsv/S.value, $Gui/Hsv/V.value) * 0.01
	var result := tracker.track(image, color, threshold, masked_image)
	if masked_image != null:
		var texture := ImageTexture.new()
		texture.create_from_image(masked_image)
		$MaskedImage.texture = texture
	return result


func marker_track(image: Image) -> Vector3:
	var tracker := MarkerTracker.new()
	return tracker.track(image)

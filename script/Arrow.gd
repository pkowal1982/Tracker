extends Sprite2D

const SPEED := 3.0
const AMPLITUDE := 32.0

var time := 0.0


func _process(delta: float) -> void:
	position.x = 128 + AMPLITUDE * abs(sin(time))
	time += delta * SPEED


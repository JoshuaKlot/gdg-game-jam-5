extends Sprite2D

@onready var start_pos = position
@onready var t = 0.

func _process(delta: float) -> void:
	t += delta
	position.y = start_pos.y + 5 * sin(t)

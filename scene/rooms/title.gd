extends Sprite2D

@onready var start_pos = position
@onready var t = 0.

func _process(delta: float) -> void:
	position.y = start_pos.y + 10 * sin(delta)

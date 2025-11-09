extends AnimatedSprite2D


var on_fire := false

func _ready() -> void:
	if _G.torch_puzzle_lit.get_or_add(position, false):
		call_deferred("enflame")
	z_index = floori(global_position.y)



func enflame() -> void:
	if not on_fire:
		_G.torch_puzzle_lit.set(position, true)
		_G.torch_puzzle_changed.emit()
		play("lit")
		on_fire = true

func extinguish() -> void:
	if on_fire:
		_G.torch_puzzle_lit.set(position, false)
		_G.torch_puzzle_changed.emit()
		play("default")
		on_fire = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Flaming"):
		enflame()
	elif area.is_in_group("Wet"):
		extinguish()

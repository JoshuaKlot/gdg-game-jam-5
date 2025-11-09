extends AnimatedSprite2D

var on_fire := false:
	set(x):
		on_fire = x
		Darkness.get_node("ColorRect").material["shader_parameter/lights_on"][id] = int(x)
@onready var id : int = _G.torch_ids.get_or_add(position, _G.torch_ids.size() + 1)
@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	if _G.torch_puzzle_lit.get_or_add(position, id == 1):
		call_deferred("enflame")
	z_index = floori(global_position.y)

func enflame() -> void:
	if not on_fire:
		Darkness.get_node("ColorRect").material["shader_parameter/size"] = 0
		for i in 40:
			Darkness.get_node("ColorRect").material["shader_parameter/size"] = i / 40. * (80 + 5 * sin(2*Time.get_unix_time_from_system()))
			await get_tree().process_frame
		$AudioStreamPlayer.play()
		_G.torch_puzzle_lit.set(position, true)
		_G.torch_puzzle_changed.emit()
		play("lit")
		on_fire = true

func extinguish() -> void:
	if on_fire:
		var s = Darkness.get_node("ColorRect").material["shader_parameter/size"]
		for i in 40:
			Darkness.get_node("ColorRect").material["shader_parameter/size"] = (39-i) / 40. * s
			await get_tree().process_frame
		for i in 9: Darkness.get_node("ColorRect").material["shader_parameter/lights_on"][1 + i] = 0
		_G.torch_puzzle_lit.set(position, false)
		_G.torch_puzzle_changed.emit()
		play("default")
		on_fire = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Flaming"):
		enflame()
		
	elif area.is_in_group("Windy"):
		extinguish()

func _process(delta):
	if on_fire:
		Darkness.get_node("ColorRect").material["shader_parameter/lights"][id] = global_position - player.get_node("Camera2D").get_screen_center_position() + Vector2(256/2, 192/2)

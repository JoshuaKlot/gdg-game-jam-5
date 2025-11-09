extends Node2D


var key_pressed := false

func _on_timer_timeout() -> void:
	if !key_pressed:
		$Torch.enflame()
	else:
		$Torch.enflame()
		get_tree().change_scene_to_file("res://scene/game.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$Torch.extinguish()
		$Timer.start()
		key_pressed = true

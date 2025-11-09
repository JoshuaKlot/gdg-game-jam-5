extends Node2D



func _on_timer_timeout() -> void:
	if $Torch.on_fire:
		$Torch.enflame()
	else:
		$Torch.enflame()
		get_tree().change_scene_to_file("res://scene/game.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$Torch.extinguish()
		$Timer.start()

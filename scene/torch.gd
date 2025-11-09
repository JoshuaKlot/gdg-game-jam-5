extends AnimatedSprite2D

var on_fire := false

func _ready() -> void:
	z_index=global_position.y
	

		
func enflame() -> void:
	if not on_fire:
		$".".play("lit")
		on_fire = true
		remove_from_group("BlockingProgress")
		_G.check_progress()
		


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Flaming"):
		enflame()
	else:
		print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
		

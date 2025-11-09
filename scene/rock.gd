extends Area2D

@export var tile_size=16
var tween: Tween

func move(distance,moveTo):
	print("moving from "+str(position)+" to "+str(position+(distance*moveTo)))
	tween=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.stop()
	tween.tween_property(self,"position",position+(distance*moveTo),0.5)
	
func _physics_process(delta: float) -> void:
	if tween:
		if tween.is_running:
			$AnimatedSprite2D.play("moving")
	else:
		$AnimatedSprite2D.play("default")

func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Windy")):
		var direction=Vector2.DOWN
		var hitFrom=area.position-position
		if abs(hitFrom.x)>abs(hitFrom.y):
			if hitFrom.x>0:
				direction=Vector2.LEFT
			else:
				direction=Vector2.RIGHT
		else:
			if hitFrom.y>0:
				direction=Vector2.DOWN
			else:
				direction=Vector2.UP
		if area.thrown:
			move(tile_size*3,direction)
		else:
			move(tile_size,direction)
	


	

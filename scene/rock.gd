extends RigidBody2D

@export var tile_size=16
@export var speed: float = 20
var direction=Vector2.DOWN
var movingTowards
var moving=false
func move(distance,moveTo):
	print("moving from "+str(position)+" to "+str(position+(distance*moveTo)))
	movingTowards=position+(distance*moveTo)
	moving=true
	
	
func _physics_process(delta: float) -> void:
	if moving:
		linear_velocity=direction*speed
		
		$AnimatedSprite2D.play("moving")
		print(position.distance_to(movingTowards))
		if position.distance_to(movingTowards) <= 0.1 or linear_velocity==Vector2.ZERO:
			moving=false
	else:
		linear_velocity=Vector2.ZERO
		$AnimatedSprite2D.play("default")
	
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Windy")):

		
		
		direction=_G.throwingDirection
		#if abs(hitFrom.x)>abs(hitFrom.y):
			#if hitFrom.x>0:
				#direction=Vector2.LEFT
			#else:
				#direction=Vector2.RIGHT
		#else:
			#if hitFrom.y>0:
				#direction=Vector2.UP
			#else:
				#direction=Vector2.DOWN
		if area.thrown:
			speed=30
			move(tile_size*3,direction)
		else:
			speed=10
			move(tile_size,direction)

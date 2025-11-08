extends Area2D


@export var thrown := false
@export var lifetime: float = 0.4
@export var max_scale: float = 5

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var alive_for: float = 0

func _physics_process(delta: float) -> void:
	var ratio := alive_for / lifetime
	if thrown:
		pass
	else:
		scale = Vector2.ONE * (max_scale * ratio)
		sprite.self_modulate.a = 1 - ratio

	alive_for += delta
	if alive_for >= lifetime:
		#queue_free()
		pass

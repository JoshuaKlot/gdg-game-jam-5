extends Area2D


@export var thrown := false
@export var lifetime: float = 0.65
@export var max_scale: float = 2.2

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var alive_for: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	var lifetime_inv = 1 / lifetime
	if thrown:
		pass
	else:
		scale = scale.move_toward(Vector2.ONE * max_scale, lifetime_inv * delta)
		sprite.self_modulate.a = move_toward(sprite.self_modulate.a, 0, lifetime_inv * delta)

	alive_for += delta
	if alive_for >= lifetime:
		queue_free()

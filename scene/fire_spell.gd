extends Area2D


@export var thrown := false
@export var lifetime: float = 0.5
@export var max_scale: Vector2 = Vector2.ONE * 1.5

var tween: Tween

func _ready() -> void:
	if thrown:
		pass
	else:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.stop()
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)

	tween.play()

	print(Time.get_ticks_msec())

func _physics_process(_delta: float) -> void:
	if tween.is_running():
		return
	queue_free()
	print(Time.get_ticks_msec())

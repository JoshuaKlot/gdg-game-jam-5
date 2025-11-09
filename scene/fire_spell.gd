extends Area2D


@export var thrown := false
@export var lifetime: float = 0.5
@export var max_scale: Vector2 = Vector2.ONE * 1.5
@export var distance: float = 100

var tween: Tween

func _ready() -> void:
	thrown=_G.throwing
	_G.throwing=false
	if thrown:
		print("I HAVE BEEN THROWN")
		tween=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.stop()
		tween.tween_property(self,"position",position+(distance*_G.throwingDirection),lifetime)
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)
	else:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.stop()
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)

	tween.play()
	
func _physics_process(_delta: float) -> void:
	if tween.is_running():
		return
	queue_free()

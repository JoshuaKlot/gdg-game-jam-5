extends Area2D


@export var thrown := false
@export var lifetime: float = 0.35
@export var max_scale: Vector2 = Vector2.ONE * 1.35
@export var distance:float = 96
var tween: Tween

func _area_entered(a: Area2D) -> void:
	if a.is_in_group("BlockSpell"):
		tween.stop()
		queue_free()

func _ready() -> void:
	area_entered.connect(_area_entered)
	thrown=_G.throwing
	_G.throwing=false
	if thrown:
		$AudioStreamPlayer.play()
		tween=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.stop()
		tween.tween_property(self,"position",position+(distance*_G.throwingDirection),lifetime)
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)
	else:
		$AudioStreamPlayer2.play()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.stop()
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)

	tween.play()
	tween.tween_callback(queue_free)

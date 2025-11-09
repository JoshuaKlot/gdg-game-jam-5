extends Area2D


@export var thrown := false
@export var lifetime: float = 0.5
@export var max_scale: Vector2 = Vector2.ONE * 1.5
@export var distance: float = 100
@onready var player = get_tree().get_first_node_in_group("Player")

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
		$AudioStreamPlayer2.play()
		tween=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.stop()
		tween.tween_property(self,"position",position+(distance*_G.throwingDirection),lifetime)
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)
	else:
		$AudioStreamPlayer.play()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.stop()
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)

	tween.play()

func _physics_process(_delta: float) -> void:
	if tween.is_running():
		Darkness.get_node("ColorRect").material["shader_parameter/lights_on"][9] = (1.5 - scale.x) * (.8/.5)
		Darkness.get_node("ColorRect").material["shader_parameter/lights"][9] = global_position - player.get_node("Camera2D").get_screen_center_position() + Vector2(256/2, 192/2)
		return
	Darkness.get_node("ColorRect").material["shader_parameter/lights_on"][9] = 0
	queue_free()

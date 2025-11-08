extends AnimatedSprite2D

@onready var area: Area2D = $Area2D

var on_fire := false
var player: Node2D = null
var item_glow := 0.0

func _area_entered(a: Area2D) -> void:
	if a.is_in_group("Flaming"):
		enflame()

func _body_entered(b: Node2D) -> void:
	if b.is_in_group("Player"):
		player = b

func _body_exited(b: Node2D) -> void:
	if b == player:
		player = null

func _ready() -> void:
	area.area_entered.connect(_area_entered)
	area.body_entered.connect(_body_entered)
	area.body_exited.connect(_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player == null:
		return

	if event.is_action_pressed("p_collect"):
		pass

func _process(delta: float) -> void:
	if player:
		item_glow = lerpf(item_glow, 1, delta * 3)
	else:
		item_glow = lerpf(item_glow, 0, delta * 2)

	self_modulate = Color.WHITE.lerp(Color(2, 2, 2, 1), item_glow)

func enflame() -> void:
	if not on_fire:
		# TODO: ignitiion sfx, play a looping sfx after?
		on_fire = true
		animation = "lit"

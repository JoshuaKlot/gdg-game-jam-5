extends Sprite2D


const LEASH_DIST_SQ := 42.0 ** 2

@onready var area: Area2D = $Area2D

var on_fire := false
var player: Node2D = null
var item_glow := 0.0
var jump_tween: Tween = null

func _area_entered(a: Area2D) -> void:
	if a.is_in_group("Flaming"):
		enflame()

func room_changed() -> void:
	if !player || !_G.inventory.has(_G.Item.TORCHFROG):
		return

	if jump_tween:
		jump_tween.stop()

	position = player.position + Vector2(randf() * 8, randf() * 8)

func _ready() -> void:
	if _G.inventory.has(_G.Item.TORCHFROG):
		cave_in()
		queue_free()
		return

	area.area_entered.connect(_area_entered)
	_G.room_changed.connect(room_changed)

func _process(delta: float) -> void:
	z_index = floori(global_position.y)
	# Sorry, not sorry
	if !player:
		player = get_tree().get_first_node_in_group("Player")
		return

	if !on_fire:
		if area.overlaps_body(player):
			item_glow = lerpf(item_glow, 1, delta * 3)
		else:
			item_glow = lerpf(item_glow, 0, delta * 2)

		self_modulate = Color.WHITE.lerp(Color(2, 2, 2, 1), item_glow)
	else:
		var diff := player.position - position
		var dist_sq := diff.length_squared()

		flip_h = diff.x < 0

		if dist_sq > LEASH_DIST_SQ && (!jump_tween || !jump_tween.is_running()):
			jump_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
			jump_tween.tween_property(self, "position", position + diff.normalized() * 36, 0.3)
			jump_tween.play()


func enflame() -> void:
	if not on_fire:
		# TODO: ignitiion sfx, play a looping sfx after?
		on_fire = true
		_G.inventory.set(_G.Item.TORCHFROG, true)
		self_modulate = Color.WHITE
		(texture as AtlasTexture).region.position = Vector2(16, 0)
		top_level = true # Don't inherit player position
		call_deferred("reparent", player)

		player.camera_shaking = true
		get_tree().create_timer(2).timeout.connect(cave_in)
		get_tree().create_timer(4).timeout.connect(func(): player.camera_shaking = false)

func cave_in() -> void:
	var t = get_tree().current_scene.get_node("Entrance/WorldLayer")
	for i in 2:
		for j in 4:
			t.set_cell(Vector2i(4 + i, 3 + j), 0, Vector2i(0 + i, 2 + j % 2))

extends CharacterBody2D


const SPEED = 140.0
const ACCEL = 1200.0
const DECEL = 1000.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera:Camera2D=$Camera2D
var sigil_layer: TileMapLayer = null
var sigil_glow: float = 0.0

var camera_shaking: bool = false

func to_tile_pos(v: Vector2) -> Vector2i:
	if sigil_layer == null:
		push_warning("Tried to use to_tile_pos when sigil_layer null")
		return Vector2.ZERO

	return sigil_layer.local_to_map(sigil_layer.to_local(v))

func nearest_sigil(v: Vector2i) -> int:
	if sigil_layer == null:
		return -1

	const NO_EXIST = Vector2i(-1, -1)

	var coords := sigil_layer.get_cell_atlas_coords(v + Vector2i.UP)
	if coords == NO_EXIST:
		coords = sigil_layer.get_cell_atlas_coords(v + Vector2i.RIGHT)
		if coords == NO_EXIST:
			coords = sigil_layer.get_cell_atlas_coords(v + Vector2i.DOWN)
			if coords == NO_EXIST:
				sigil_layer.get_cell_atlas_coords(v + Vector2i.LEFT)
				if coords == NO_EXIST:
					return -1

	return _G.coords_to_sigil(coords)


func room_changed() -> void:
	camera.reset_smoothing()
	camera.limit_left=_G.camera_constraints[_G.currentRoom][0]
	camera.limit_top=_G.camera_constraints[_G.currentRoom][1]
	camera.limit_right=_G.camera_constraints[_G.currentRoom][2]
	camera.limit_bottom=_G.camera_constraints[_G.currentRoom][3]
	sigil_layer = get_tree().get_first_node_in_group("SigilLayer")
	for i in 9:
		Darkness.get_node("ColorRect").material["shader_parameter/lights_on"][1 + i] = 0

func _ready() -> void:
	_G.room_changed.connect(room_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p_collect"):
		var sigil := nearest_sigil(to_tile_pos(position))
		if sigil >= 0:
			_G.collect_sigil(sigil)

func _physics_process(delta: float) -> void:
	var move_vec := Vector2.ZERO if camera_shaking else Input.get_vector("p_left", "p_right", "p_up", "p_down")
	z_index = floori(global_position.y)

	if move_vec:
		velocity = velocity.move_toward(move_vec * SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECEL * delta)

	if velocity:
		if velocity.abs().max_axis_index() == Vector2.AXIS_X:
			sprite.play("side")
			sprite.flip_h = velocity.x >= 0
		else:
			sprite.play("front" if velocity.y >= 0 else "back")
	else:
		sprite.stop()

	move_and_slide()

	var player_tile := to_tile_pos(position)
	if nearest_sigil(player_tile) >= 0:
		sigil_glow = lerpf(sigil_glow, 1, delta * 2)
	else:
		sigil_glow = lerpf(sigil_glow, 0, delta * 3)

	sigil_layer.self_modulate = Color.WHITE.lerp(Color(2.2, 2.2, 2.2, 1), sigil_glow)

	@warning_ignore("integer_division")
	Darkness.get_node("ColorRect").material["shader_parameter/pos"] = global_position - $Camera2D.get_screen_center_position() + Vector2(256/2, 192/2)
	if _G.inventory.has(_G.Item.TORCHFROG) and get_children().size() >= 4:
		@warning_ignore("integer_division")
		Darkness.get_node("ColorRect").material["shader_parameter/lights"][0] = get_tree().get_first_node_in_group("TorchFrog").global_position - $Camera2D.get_screen_center_position() + Vector2(256/2, 192/2)
	Darkness.get_node("ColorRect").material["shader_parameter/size"] = 80 + 10 * sin(2*Time.get_unix_time_from_system())

	if camera_shaking: $Camera2D.offset = 2*Vector2(randf()*2-1, randf()*2-1)
	else: $Camera2D.offset = Vector2.ZERO

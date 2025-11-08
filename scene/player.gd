extends CharacterBody2D


const SPEED = 200.0
const ACCEL = 2400.0
const DECEL = 1000.0

var sigil_layer: TileMapLayer = null

@onready var debug_infront_tile := $DebugTileInFront

func to_tile_pos(v: Vector2) -> Vector2i:
	if sigil_layer == null:
		push_warning("Tried to use to_tile_pos when sigil_layer null")
		return Vector2.ZERO

	return sigil_layer.local_to_map(sigil_layer.to_local(v))

func near_sigil(v: Vector2i) -> bool:
	const NO_EXIST = Vector2i(-1, -1)

	return sigil_layer.get_cell_atlas_coords(v + Vector2i.UP) != NO_EXIST || \
		sigil_layer.get_cell_atlas_coords(v + Vector2i.RIGHT) != NO_EXIST || \
		sigil_layer.get_cell_atlas_coords(v + Vector2i.DOWN) != NO_EXIST || \
		sigil_layer.get_cell_atlas_coords(v + Vector2i.LEFT) != NO_EXIST


func _ready() -> void:
	sigil_layer = get_tree().get_first_node_in_group("SigilLayer")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p_cast"):
		var spell = Globals.spells.get(Globals.SigNames.Fire).instantiate()
		spell.global_position = position

		get_tree().root.add_child(spell)

func _physics_process(delta: float) -> void:
	var move_vec := Input.get_vector("p_left", "p_right", "p_up", "p_down")

	if move_vec:
		velocity = velocity.move_toward(move_vec * SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECEL * delta)

	move_and_slide()

	var player_tile := to_tile_pos(position)
	debug_infront_tile.global_position = player_tile * sigil_layer.tile_set.tile_size

	if near_sigil(player_tile):
		debug_infront_tile.self_modulate = Color.GREEN
		sigil_layer.self_modulate = Color.GREEN
	else:
		debug_infront_tile.self_modulate = Color.WHITE
		sigil_layer.self_modulate = Color.WHITE

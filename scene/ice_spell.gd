extends Area2D


const CHECK_OFFSETS: Array[Vector2i] = [
	Vector2i.ZERO,
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]
const ICE_OFFSET := Vector2i(0, 6)
const ATLAS_WATER_MINY := 6
const ATLAS_WATER_MAXY := 8

@export var thrown := false
@export var lifetime: float = 0.5
@export var max_scale: Vector2 = Vector2.ONE * 1.2
@export var distance: float = 64
@export var max_freeze_count: int = 7

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var freeze_count := 0
var tween: Tween
var world_layer: TileMapLayer
var dying := false

func to_tile_pos(v: Vector2) -> Vector2i:
	if world_layer == null:
		push_warning("Tried to use to_tile_pos when world_layer null")
		return Vector2.ZERO

	return world_layer.local_to_map(world_layer.to_local(v))

func die() -> void:
	dying = true
	tween.stop()
	sprite.play("break")
	await sprite.animation_finished
	queue_free()

func _ready() -> void:
	world_layer = get_tree().get_first_node_in_group("WorldLayer")
	if world_layer == null:
		push_warning("no node in WorldLayer group")

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.stop()

	thrown=_G.throwing
	_G.throwing=false
	if thrown:
		tween.tween_property(self,"position",position+(distance*_G.throwingDirection),lifetime)
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)
	else:
		tween.tween_property(self, "scale", max_scale, lifetime)
		tween.tween_property(self, "modulate:a", 0, lifetime + 0.1)

	tween.play()
	tween.tween_callback(die)

func _physics_process(_delta: float) -> void:
	if dying:
		return
	if world_layer == null:
		return

	var base_pos := to_tile_pos(position)

	for offset in CHECK_OFFSETS:
		var tile_pos := base_pos + offset
		if world_layer.get_cell_tile_data(tile_pos).get_custom_data("is_water"):
			var cur_coords := world_layer.get_cell_atlas_coords(tile_pos)
			if cur_coords.y >= ATLAS_WATER_MINY && cur_coords.y <= ATLAS_WATER_MAXY:
				world_layer.set_cell(tile_pos, 0, cur_coords + ICE_OFFSET)
				freeze_count += 1
				if freeze_count >= max_freeze_count:
					die()
					return

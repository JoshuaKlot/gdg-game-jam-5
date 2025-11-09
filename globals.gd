extends Node


var casting := false
var can_cast := true
@warning_ignore("unused_signal")
signal can_cast_changed(can: bool)
var canThrow := true
var throwing = false
var throwingDirection = Vector2.DOWN

enum Spell {
	FIRE,
	AIR,
}

const atlas_tile_size := Vector2i(16, 16)
const atlas_size := Vector2i(4, 4)
const sigil_atlas_coords: Dictionary[int, Vector2i] = {
	Spell.FIRE: atlas_tile_size * Vector2i(0, 0),
	Spell.AIR: atlas_tile_size * Vector2i(1, 0),
}

var collected_sigils: Array[int] = []
signal sigil_collected(sigil: int)

const spell_scenes: Dictionary[int, PackedScene] = {
	Spell.FIRE: preload("res://scene/fire_spell.tscn"),
	Spell.AIR: preload("res://scene/air_spell.tscn"),
}
@warning_ignore("unused_signal")
signal request_cast_spell(spell: int)

func collect_sigil(s: int) -> bool:
	if s in collected_sigils:
		return false

	collected_sigils.append(s)
	sigil_collected.emit(s)
	return true

func coords_to_sigil(v: Vector2i) -> int:
	v *= atlas_tile_size # We're looking at atlas coordinates which are in absolute pixels, not col by row
	for sigil in sigil_atlas_coords:
		if sigil_atlas_coords.get(sigil) == v:
			return sigil

	return -1


enum Item {
	TORCHFROG,
}

var inventory: Dictionary[int, bool] = {}
signal inventory_changed(item: int)

func inventory_set(item: int, b: bool = true) -> void:
	inventory.set(item, b)
	inventory_changed.emit(item)


enum Room {
	ENTRANCE,
	TORCH_PUZ
}

var camera_constraints:Dictionary[int,Array]={
	Room.ENTRANCE: [64,-16,288,160],
	Room.TORCH_PUZ: [0,0,416,288]
}

# Using preload makes doorway.tscn die, can't use const dict
var room_to_scene: Dictionary[int, PackedScene] = {
	Room.ENTRANCE: load("res://scene/rooms/0_entrance.tscn"),
	Room.TORCH_PUZ: load("res://scene/rooms/1_torch_puzzle.tscn"),
}

@warning_ignore("unused_signal")
signal request_room_change(room: int)
@warning_ignore("unused_signal")
signal room_changed(room: int)


var torch_puzzle_lit: Dictionary[Vector2, bool] = {}
var torch_ids: Dictionary[Vector2, int] = {}
@warning_ignore("unused_signal")
signal torch_puzzle_changed
var torch_puzzle_solved := false

func torch_puzzle_all_lit() -> bool:
	var count := 0
	for torch_pos in torch_puzzle_lit:
		count += 1
		if !torch_puzzle_lit[torch_pos]:
			return false
	return count > 0

func play_sound(stream: AudioStream, parent: Node = null, pitch = 1.0):
	var a = AudioStreamPlayer.new()
	a.stream = stream
	a.pitch_scale = pitch
	a.process_mode = PROCESS_MODE_ALWAYS
	a.finished.connect(a.queue_free)
	if parent: parent.add_child(a)
	else: add_child(a)
	a.play()

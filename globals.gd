extends Node


var currentRoom := 0
var casting := false
var progressBlocked := false

enum Spell {
	FIRE,
}

const atlas_tile_size := Vector2i(16, 16)
const atlas_size := Vector2i(4, 4)
const sigil_atlas_coords: Dictionary[int, Vector2i] = {
	Spell.FIRE: atlas_tile_size * Vector2i(0, 0),
}

var collected_sigils: Array[int] = []
signal sigil_collected(sigil: int)

const spell_scenes: Dictionary[int, PackedScene] = {
	Spell.FIRE: preload("res://scene/fire_spell.tscn")
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
	var sigil := v.y * atlas_size.x + v.x
	if sigil < 0 || sigil > atlas_size.x * atlas_size.y:
		push_error("tried to access coords {0} outside of atlas {1}".format([v, atlas_size]))
		return -1

	if sigil >= sigil_atlas_coords.size():
		push_error("tried to access sigil {0} outside of size {1}".format([sigil, sigil_atlas_coords.size()]))
		return -1

	return sigil
func check_progress():
	var num_obstuctions=get_tree().get_nodes_in_group("BlockingProgress")
	if(num_obstuctions.size()>0):
		print("Blocking Progress: "+str(num_obstuctions.size()))
		progressBlocked=true
	else:
		print("Progress unimpeeded. Continue")
		progressBlocked=false

enum Item {
	TORCHFROG,
}

var inventory: Dictionary[int, bool] = {}


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
signal request_room_change(room_scene: PackedScene)
@warning_ignore("unused_signal")
signal room_changed

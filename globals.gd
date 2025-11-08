extends Node

enum Spell {
	FIRE,
}
const sigil_atlas_coords: Dictionary[int, Vector2] = {
	Spell.FIRE: Vector2i(0, 0),
}
var collected_sigils: Dictionary[int, bool] = {}
var spell_scenes: Dictionary[int, PackedScene] = {
	Spell.FIRE: preload("res://scene/fire_spell.tscn")
}

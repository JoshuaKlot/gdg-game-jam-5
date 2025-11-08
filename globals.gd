extends Node

enum SigNames {
	Fire,
}

var sigils: Dictionary[int, bool] = {}

var spells: Dictionary[int, PackedScene] = {
	SigNames.Fire: preload("res://scene/fire_spell.tscn")
}

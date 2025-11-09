extends Node2D


func check_torches() -> void:
	$BlockUntilAllLitLayer.enabled = !_G.torch_puzzle_all_lit()

func _ready() -> void:
	_G.torch_puzzle_changed.connect(check_torches)
	check_torches()

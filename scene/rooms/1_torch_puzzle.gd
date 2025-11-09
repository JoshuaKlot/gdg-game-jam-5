extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")

func check_torches() -> void:
	if $BlockUntilAllLitLayer.enabled and _G.torch_puzzle_all_lit():
		player.camera_shaking = true
		get_tree().create_timer(1).timeout.connect(func(): $BlockUntilAllLitLayer.enabled = false)
		get_tree().create_timer(1.5).timeout.connect(func(): player.camera_shaking = false)
		_G.torch_puzzle_solved = true

func _ready() -> void:
	_G.torch_puzzle_changed.connect(check_torches)
	$BlockUntilAllLitLayer.enabled = !_G.torch_puzzle_solved

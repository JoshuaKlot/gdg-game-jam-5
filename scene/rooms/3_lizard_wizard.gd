extends Node2D


@onready var crown: Area2D = $Crown
@onready var king_lizard: Sprite2D = $KingLizard
@onready var block_layer: TileMapLayer = $BlockUntilSolved
@onready var player = get_tree().get_first_node_in_group("Player")

func crown_entered(a: Area2D) -> void:
	if a.is_in_group("LizardTongue"):
		await get_tree().create_timer(king_lizard.hold_duration * 1.5).timeout
		crown.reparent(king_lizard.find_child("Tongue"))
		await get_tree().create_timer(king_lizard.retract_tween_duration * 1.2).timeout
		player.camera_shaking = true
		get_tree().create_timer(1).timeout.connect(func(): block_layer.enabled = false)
		get_tree().create_timer(1.5).timeout.connect(func(): player.camera_shaking = false)
		_G.lizard_wizard_solved = true

func _ready() -> void:
	if _G.lizard_wizard_solved:
		crown.reparent(king_lizard.find_child("Tongue"))
		block_layer.enabled = false
		return

	crown.area_entered.connect(crown_entered)

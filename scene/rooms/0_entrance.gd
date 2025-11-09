extends Node2D


@onready var abs_darkness: Sprite2D = $AbsoluteDarkness

func inv_changed(item: int) -> void:
	if item == _G.Item.TORCHFROG:
		abs_darkness.queue_free()

func _ready() -> void:
	if _G.inventory.has(_G.Item.TORCHFROG):
		abs_darkness.queue_free()
		return

	_G.inventory_changed.connect(inv_changed)

extends AnimatedSprite2D

@onready var area: Area2D = $Area2D

var on_fire := false

func _area_entered(a: Area2D) -> void:
	print(a.get_path())
	if a.is_in_group("Flaming"):
		enflame()

func _ready() -> void:
	area.area_entered.connect(_area_entered)

func enflame() -> void:
	if not on_fire:
		# TODO: ignitiion sfx, play a looping sfx after?
		on_fire = true
		animation = "lit"

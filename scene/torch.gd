extends AnimatedSprite2D

@onready var area: Area2D = $Area2D
@onready var flame_audio: AudioStreamPlayer2D = $FlameAudio

var on_fire := false

func _area_entered(a: Area2D) -> void:
	print(a.get_path())
	if a.is_in_group("Flaming"):
		enflame()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.area_entered.connect(_area_entered)
	pass # Replace with function body.

func enflame() -> void:
	if not on_fire:
		# Do stuff: play ignition sound
		on_fire = true
		animation = "lit"
		flame_audio.play()

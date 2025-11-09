extends Node2D


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var light: PointLight2D = $PointLight2D
@onready var particles: CPUParticles2D = $CPUParticles2D

func play_effect(_s) -> void:
	light.enabled = true
	anim_player.play("fade_light")
	particles.emitting = true
	await anim_player.animation_finished
	light.enabled = false

func _ready() -> void:
	_G.sigil_collected.connect(play_effect)

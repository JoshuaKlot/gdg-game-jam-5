extends Node2D


# TODO (after jam probably): just use a separate animation and one
# AnimationPlayer for this

@onready var learned_anim_player: AnimationPlayer = $Learned/AnimationPlayer
@onready var learned_light: PointLight2D = $Learned/PointLight2D
@onready var learned_particles: CPUParticles2D = $Learned/CPUParticles2D

@onready var castready_anim_player: AnimationPlayer = $CastReady/AnimationPlayer
@onready var castready_light: PointLight2D = $CastReady/PointLight2D
@onready var castready_particles: CPUParticles2D = $CastReady/CPUParticles2D

func sigil_collected(_s) -> void:
	learned_light.enabled = true
	learned_anim_player.play("fade_light")
	learned_particles.emitting = true
	await learned_anim_player.animation_finished
	learned_light.enabled = false

func can_cast_changed(can: bool):
	if !can:
		return

	castready_light.enabled = true
	castready_anim_player.play("fade_light")
	castready_particles.emitting = true
	await castready_anim_player.animation_finished
	castready_light.enabled = false


func _ready() -> void:
	_G.sigil_collected.connect(sigil_collected)
	_G.can_cast_changed.connect(can_cast_changed)

extends Control


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var container: HFlowContainer = $HFlowContainer
@onready var spell_rect := preload("res://scene/spell_rect.tscn")
@onready var throw_mod: TextureRect = $HFlowContainer/ThrowMod

func append_spell(spell: int) -> void:
	var new_rect: TextureRect = spell_rect.instantiate()
	new_rect.spell = spell
	new_rect.index = _G.collected_sigils.size() - 1
	container.add_child(new_rect)
	new_rect.call("redraw")

func cast_requested(_spell) -> void:
	visible = false

func _ready() -> void:
	visible = false
	_G.sigil_collected.connect(append_spell)
	_G.request_cast_spell.connect(cast_requested)

func _unhandled_input(event: InputEvent) -> void:
	if _G.collected_sigils.size() == 0:
		return

	if !_G.can_cast:
		return

	if event.is_action_pressed("p_cast") and !_G.casting:
		_G.casting = true
		if _G.canThrow:
			throw_mod.process_mode = Node.PROCESS_MODE_INHERIT
			throw_mod.visible = true

		# anim_player.play("appear", -1, 5)
	elif event.is_action_pressed("cast_cancel") and _G.casting:
		_G.casting = false
		_G.throwing=false

	visible = _G.casting

extends Control


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var container: HFlowContainer = $HFlowContainer
@onready var spell_rect := preload("res://scene/spell_rect.tscn")


func append_spell(spell: int) -> void:
	var new_rect: TextureRect = spell_rect.instantiate()
	new_rect.spell = spell
	new_rect.index = _G.collected_sigils.size() - 1
	container.add_child(new_rect)
	new_rect.call("redraw")

func _ready() -> void:
	visible = false
	_G.sigil_collected.connect(append_spell)

func _unhandled_input(event: InputEvent) -> void:
	if _G.collected_sigils.size() == 0:
		return
	if event.is_action_pressed("throw_toggle") and _G.casting and _G.canThrow:
		if _G.throwing:
			print("off")
			_G.throwing=false
		else:
			print("on")
			_G.throwing=true
	if event.is_action_pressed("p_cast") and !_G.casting:
		_G.casting = true
		# anim_player.play("appear", -1, 5)
	elif event.is_action_pressed("cast_cancel") and _G.casting:
		_G.casting = false
		_G.throwing=false

	visible = _G.casting

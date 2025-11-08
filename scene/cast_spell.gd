extends Control


@onready var container: HFlowContainer = $HFlowContainer
@onready var spell_rect := preload("res://scene/spell_rect.tscn")

var casting := false

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
	if event.is_action_pressed("p_cast") and not casting:
		casting = true
		visible = true
	elif event.is_action_pressed("cast_cancel") and casting:
		casting = false
		visible = false

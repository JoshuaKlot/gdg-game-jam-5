extends TextureRect


@export var spell: int = -1 # Use _G.Spell when setting this
@export var index: int = -1 # The index of the spell when presented in the cast UI

@onready var label: RichTextLabel = $TextureRect/RichTextLabel

var action_name := ""

func _ready() -> void:
	# Same issue as with the lizards. All spell_rect share the same AtlasTexture
	# and affect each other.
	texture = texture.duplicate()

func redraw() -> void:
	assert(spell != -1, "spell must be set before redraw")
	assert(index != -1, "index must be set before redraw")

	(texture as AtlasTexture).region.position = _G.sigil_atlas_coords[spell] as Vector2

	action_name = "cast_slot{0}".format([index])
	var actions := InputMap.action_get_events(action_name)
	if !actions:
		push_warning("no actions found for index {0}".format([index]))
		return

	for a in actions:
		if a is InputEventKey:
			label.text = OS.get_keycode_string(a.physical_keycode)
			break

func _unhandled_input(event: InputEvent) -> void:
	if index < 0:
		return

	if _G.casting && event.is_action_pressed(action_name):
		#_G.spell_scenes[spell].thrown=_G.throwing
		_G.request_cast_spell.emit(spell)

extends TextureRect


@export var spell: int = -1 # Use _G.Spell when setting this
@export var index: int = -1 # The index of the spell when presented in the cast UI

@onready var label: RichTextLabel = $TextureRect/RichTextLabel

func redraw() -> void:
	assert(spell != -1, "spell must be set before redraw")
	assert(index != -1, "index must be set before redraw")

	(texture as AtlasTexture).region.position = _G.sigil_atlas_coords[spell] as Vector2

	var actions := InputMap.action_get_events("cast_slot{0}".format([index]))
	if !actions:
		push_warning("no actions found for index {0}".format([index]))
		return

	for a in actions:
		if a is InputEventKey:
			label.text = OS.get_keycode_string(a.physical_keycode)
			break

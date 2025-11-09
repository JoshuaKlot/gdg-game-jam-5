extends TextureRect


const SHIFT_MAP: Dictionary[String, String] = {
	"C": "c",
	"1": "!",
	"2": "@",
	"3": "#",
	"4": "$",
}

@export var spell: int = -1 # Use _G.Spell when setting this
@export var index: int = -1 # The index of the spell when presented in the cast UI
@export var is_throw_mod := false

@onready var label: RichTextLabel = $TextureRect/RichTextLabel

var action_name := ""

func _ready() -> void:
	# Same issue as with the lizards. All spell_rect share the same AtlasTexture
	# and affect each other.
	texture = texture.duplicate()
	redraw()

func redraw() -> void:
	if is_throw_mod:
		label.text = SHIFT_MAP[OS.get_keycode_string(InputMap.action_get_events("throw_toggle")[0].physical_keycode)]
		return

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
			label.text = SHIFT_MAP[OS.get_keycode_string(a.physical_keycode)]
			break

func _unhandled_input(event: InputEvent) -> void:
	if is_throw_mod:
		if _G.casting && event.is_action_pressed("throw_toggle"):
			_G.throwing = !_G.throwing

		self_modulate = Color.FIREBRICK if _G.throwing else Color.WHITE
		return

	if index < 0:
		return

	if _G.casting && event.is_action_pressed(action_name):
		#_G.spell_scenes[spell].thrown=_G.throwing
		_G.request_cast_spell.emit(spell)

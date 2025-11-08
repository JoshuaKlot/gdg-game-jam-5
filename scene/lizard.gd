extends Sprite2D


const TONGUE_OFFSET := Vector2(0, -8)

@export var extend_tween_duration := 0.7
@export var retract_tween_duration := 0.2
@export var hold_duration := 0.4
@export var tongue_length := 32.0
@export var steppable := false

@onready var detect_tongue: Area2D = $DetectTongue
@onready var tongue: Area2D = $Tongue
@onready var tongue_line: Line2D = $TongueLine

var extend_tween: Tween
var retract_tween: Tween
var extending := false
static var extend_count := 0

func rebuild_tweens() -> void:
	extend_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	extend_tween.stop()
	extend_tween.tween_property(tongue, "position", TONGUE_OFFSET + Vector2(0, -tongue_length), extend_tween_duration)
	extend_tween.tween_callback(extend_done)

	retract_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	retract_tween.stop()
	retract_tween.tween_property(tongue, "position", TONGUE_OFFSET, retract_tween_duration)
	retract_tween.tween_callback(retract_done)

func retract_done() -> void:
	extend_count -= 1
	tongue_line.set_point_position(1, Vector2.ZERO)
	extending = false

	rebuild_tweens()


func extend_done() -> void:
	await get_tree().create_timer(hold_duration).timeout
	retract_tween.play()

func tongue_detected(a: Area2D):
	if !a.is_in_group("LizardTongue") || a == tongue || extending:
		return

	extend_tween.play()
	extending = true
	extend_count += 1

	if steppable:
		print("stepped")

# Only steppable lizards connect this
func body_entered(b: Node2D) -> void:
	if !b.is_in_group("Player") || extending || extend_count > 0:
		return

	extend_tween.play()
	extending = true
	extend_count += 1

func _ready() -> void:
	rebuild_tweens()

	if steppable:
		texture = texture.duplicate()
		(texture as AtlasTexture).region.position = Vector2(16, 0)
		detect_tongue.body_entered.connect(body_entered)

	detect_tongue.area_entered.connect(tongue_detected)

func _process(_delta: float) -> void:
	if extend_tween.is_running():
		tongue_line.set_point_position(1, \
			tongue.position - TONGUE_OFFSET)
	elif retract_tween.is_running():
		tongue_line.set_point_position(1, \
			tongue.position - TONGUE_OFFSET)

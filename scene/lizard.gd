extends Sprite2D


const TONGUE_OFFSET := Vector2(0, -8)
const SPIN_TOTAL := 2.5 * PI

@export var extend_tween_duration := 0.7
@export var retract_tween_duration := 0.2
@export var hold_duration := 0.4
@export var tongue_length := 32.0
@export var steppable := false
@export var spinnable := true

@onready var detector: Area2D = $Detector
@onready var tongue: Area2D = $Tongue
@onready var tongue_line: Line2D = $TongueLine

var extend_tween: Tween
var retract_tween: Tween
var wind_spin_tween: Tween
var extending := false
static var extend_count := 0

func rebuild_tongue_tweens() -> void:
	extend_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	extend_tween.stop()
	extend_tween.tween_property(tongue, "position", TONGUE_OFFSET + Vector2(0, -tongue_length), extend_tween_duration)
	extend_tween.tween_callback(extend_done)

	retract_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	retract_tween.stop()
	retract_tween.tween_property(tongue, "position", TONGUE_OFFSET, retract_tween_duration)
	retract_tween.tween_callback(retract_done)

func rebuild_spin_tween() -> void:
	wind_spin_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	wind_spin_tween.stop()
	wind_spin_tween.tween_property(self, "rotation", rotation + SPIN_TOTAL, 1)
	wind_spin_tween.tween_callback(rebuild_spin_tween)

func retract_done() -> void:
	tongue.monitorable = true
	extend_count -= 1
	tongue_line.set_point_position(1, Vector2.ZERO)
	extending = false

	rebuild_tongue_tweens()


func extend_done() -> void:
	tongue.monitorable = false
	await get_tree().create_timer(hold_duration).timeout
	retract_tween.play()

func detector_entered(a: Area2D):
	if a.is_in_group("LizardTongue") && a != tongue && !extending:
		extend_tween.play()
		extending = true
		$AudioStreamPlayer.play()
		extend_count += 1
	elif spinnable && !extending && !steppable && a.is_in_group("Windy") && !wind_spin_tween.is_running():
		wind_spin_tween.play()

# Only steppable lizards connect this
func body_entered(b: Node2D) -> void:
	if !b.is_in_group("Player") || extending || extend_count > 0:
		return

	extend_tween.play()
	extending = true
	$AudioStreamPlayer.play()
	extend_count += 1

func _ready() -> void:
	rebuild_tongue_tweens()
	rebuild_spin_tween()

	if steppable:
		texture = texture.duplicate() # texture is shared among all lizards, only change this one via dupe
		(texture as AtlasTexture).region.position = Vector2(16, 0)
		detector.body_entered.connect(body_entered)

	detector.area_entered.connect(detector_entered)

func _exit_tree() -> void:
	if extending:
		extend_count -= 1
		extending = false

func _process(_delta: float) -> void:
	if extend_tween.is_running():
		tongue_line.set_point_position(1, \
			tongue.position - TONGUE_OFFSET)
	elif retract_tween.is_running():
		tongue_line.set_point_position(1, \
			tongue.position - TONGUE_OFFSET)

extends Node2D


const PLAYER := preload("res://scene/player.tscn")

@onready var cur_room: Node2D = null
@onready var old_room: Node2D = null
@onready var cur_room_source: PackedScene = null
@onready var player: CharacterBody2D = null

var cur_room_int := 0
var old_room_int
var is_transitioning := false
var transition_conflict := false

func change_room(room: int) -> void:
	if is_transitioning:
		print(old_room_int, room, cur_room_int)
		if old_room_int != room: return
		transition_conflict = true
		while transition_conflict: await get_tree().process_frame

	old_room = cur_room
	old_room_int = cur_room_int

	cur_room_int = room
	is_transitioning = true
	var room_scene: PackedScene = _G.room_to_scene.get(room)
	if room_scene == null:
		push_error("room {0} has no scene mapped to it".format([room]))
		return

	player.process_mode = Node.PROCESS_MODE_DISABLED

	var s = Darkness.get_node("ColorRect").material["shader_parameter/size"]
	for i in 40:
		Darkness.get_node("ColorRect").material["shader_parameter/size"] = (39-i) / 40. * s
		await get_tree().process_frame
	for i in 9: Darkness.get_node("ColorRect").material["shader_parameter/lights_on"][1 + i] = 0

	if old_room: old_room.queue_free()

	await get_tree().process_frame

	cur_room = room_scene.instantiate()
	add_child(cur_room)

	await get_tree().process_frame

	var spawn_at: Node2D = get_tree().get_first_node_in_group("PlayerSpawn")
	for e: Node2D in get_tree().get_nodes_in_group("DoorwayExit"):
		if _G.room_to_scene[e.spawn_from] == cur_room_source:
			spawn_at = e
			break

	if spawn_at == null:
		push_error("no contiguous DoorwayExit nor PlayerSpawn found, using first DoorwayExit (room {0} -> {1})".format([old_room_int, cur_room_int]))
		spawn_at = get_tree().get_first_node_in_group("DoorwayExit")

	player.position = spawn_at.position

	cur_room_source = room_scene

	_G.room_changed.emit(room)
	player.set_deferred("process_mode", PROCESS_MODE_INHERIT)

	Darkness.get_node("ColorRect").material["shader_parameter/size"] = 0
	for i in 40:
		Darkness.get_node("ColorRect").material["shader_parameter/size"] = i / 40. * (80 + 5 * sin(2*Time.get_unix_time_from_system()))
		if transition_conflict:
			transition_conflict = false
			is_transitioning = false
			return
		await get_tree().process_frame

	is_transitioning = false

func cast_spell(spell: int) -> void:
	var new := _G.spell_scenes[spell].instantiate()
	new.position = player.position
	add_child(new)
	_G.casting = false

	# No regrets
	_G.can_cast = false
	_G.can_cast_changed.emit(false)
	await get_tree().create_timer(1.5).timeout
	_G.can_cast = true
	_G.can_cast_changed.emit(true)

func _ready() -> void:
	_G.request_room_change.connect(change_room)
	_G.request_cast_spell.connect(cast_spell)

	player = PLAYER.instantiate()
	change_room(_G.Room.ENTRANCE)
	add_child(player)

	#var spawn: Node2D = get_tree().get_first_node_in_group("PlayerSpawn")
	#assert(spawn != null, "no Node in group PlayerSpawn found")
	var spawn: Node2D = null
	while not spawn:
		spawn = get_tree().get_first_node_in_group("PlayerSpawn")
		await get_tree().process_frame

	player.position = spawn.position

func _unhandled_input(event: InputEvent) -> void:
	if !OS.has_feature("editor"):
		return

	if event.is_action_pressed("debug_prev_room") && !is_transitioning:
		var frog := get_tree().get_first_node_in_group("TorchFrog")
		if frog:
			frog.call("enflame")

		cur_room_int -= 1
		if cur_room_int < 0:
			cur_room_int = _G.Room.size() - 1

		print("DEBUG: goto prev room ", cur_room_int)
		change_room(cur_room_int)
	elif event.is_action_pressed("debug_next_room") && !is_transitioning:
		var frog := get_tree().get_first_node_in_group("TorchFrog")
		if frog:
			frog.call("enflame")

		cur_room_int += 1
		if cur_room_int >= _G.Room.size():
			cur_room_int = 0

		print("DEBUG: goto next room ", cur_room_int)
		change_room(cur_room_int)
	elif event.is_action_pressed("debug_collect_next_sigil"):
		var next_sigil := _G.collected_sigils.size()
		if next_sigil == _G.Spell.size():
			print("DEBUG: already have all sigils")
			return

		_G.collected_sigils.append(next_sigil)
		_G.sigil_collected.emit(next_sigil)
		print("DEBUG: force collect sigil ", next_sigil)

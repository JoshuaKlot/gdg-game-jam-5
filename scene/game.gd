extends Node2D


const PLAYER := preload("res://scene/player.tscn")

@onready var cur_room: Node2D = null
@onready var cur_room_source: PackedScene = null
@onready var player: CharacterBody2D = null
var is_transitioning := false

func change_room(room: int) -> void:
	is_transitioning = true
	var room_scene: PackedScene = _G.room_to_scene.get(room)
	if room_scene == null:
		push_error("room {0} has no scene mapped to it".format([room]))
		return

	var old_room = cur_room

	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	var s = Darkness.get_node("ColorRect").material["shader_parameter/size"]
	for i in 40:
		Darkness.get_node("ColorRect").material["shader_parameter/size"] = (39-i) / 40. * s
		await get_tree().process_frame
	for i in 9: Darkness.get_node("ColorRect").material["shader_parameter/lights_on"][1 + i] = 0

	if old_room: old_room.queue_free()
	
	cur_room = room_scene.instantiate()
	add_child(cur_room)
	
	await get_tree().process_frame

	var spawn_at: Node2D = get_tree().get_first_node_in_group("PlayerSpawn")
	for e: Node2D in get_tree().get_nodes_in_group("DoorwayExit"):
		if _G.room_to_scene[e.spawn_from] == cur_room_source:
			spawn_at = e
			break

	player.position = spawn_at.position

	cur_room_source = room_scene
	
	_G.room_changed.emit(room)
	player.set_deferred("process_mode", PROCESS_MODE_INHERIT)
	
	Darkness.get_node("ColorRect").material["shader_parameter/size"] = 0
	for i in 40:
		Darkness.get_node("ColorRect").material["shader_parameter/size"] = i / 40. * (80 + 5 * sin(2*Time.get_unix_time_from_system()))
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

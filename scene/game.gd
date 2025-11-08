extends Node2D


var ENTRANCE := _G.room_to_scene[_G.Room.ENTRANCE]
const PLAYER := preload("res://scene/player.tscn")

@onready var cur_room: Node2D = null
@onready var cur_room_source: PackedScene = null
@onready var player: CharacterBody2D = null

func change_room(room: PackedScene) -> void:
	if cur_room:
		cur_room.queue_free()
		await get_tree().process_frame

	player.process_mode = Node.PROCESS_MODE_DISABLED

	cur_room = room.instantiate()
	add_child(cur_room)

	await get_tree().process_frame

	var spawn_at: Node2D = get_tree().get_first_node_in_group("PlayerSpawn")
	for e: Node2D in get_tree().get_nodes_in_group("DoorwayExit"):
		if _G.room_to_scene[e.spawn_from] == cur_room_source:
			spawn_at = e
			break

	player.position = spawn_at.position

	cur_room_source = room

	_G.room_changed.emit()
	player.set_deferred("process_mode", PROCESS_MODE_INHERIT)

func _ready() -> void:
	_G.request_room_change.connect(change_room)

	player = PLAYER.instantiate()
	change_room(ENTRANCE)
	add_child(player)

	var spawn: Node2D = get_tree().get_first_node_in_group("PlayerSpawn")
	assert(spawn != null, "no Node in group PlayerSpawn found")

	player.position = spawn.position

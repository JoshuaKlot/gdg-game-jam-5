extends Area2D


@export var load_room: int

func _body_entered(b: Node2D) -> void:
	if b.is_in_group("Player"):
		_G.request_room_change.emit(load_room)


func _ready() -> void:
	body_entered.connect(_body_entered)

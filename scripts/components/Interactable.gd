extends Area2D
## Generic interact volume. Player presses interact while overlapping.

signal interacted(by: Node)
signal player_entered(body: Node)
signal player_exited(body: Node)

@export var enabled: bool = true
@export var require_player_group: bool = true
@export var player_group: String = "player"

var _bodies_inside: Array[Node] = []


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return
	if not event.is_action_pressed("interact"):
		return
	if _bodies_inside.is_empty():
		return
	var by := _bodies_inside[0]
	interacted.emit(by)
	get_viewport().set_input_as_handled()


func _on_body_entered(body: Node) -> void:
	if require_player_group and not body.is_in_group(player_group):
		return
	if not _bodies_inside.has(body):
		_bodies_inside.append(body)
	player_entered.emit(body)


func _on_body_exited(body: Node) -> void:
	_bodies_inside.erase(body)
	player_exited.emit(body)

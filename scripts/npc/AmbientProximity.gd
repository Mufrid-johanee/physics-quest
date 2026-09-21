extends Area2D
## Automatic proximity ambient dialogue. No E/F. Re-arms after leave/re-enter.
## Does not move or scale parent. Scene-authored transforms stay authoritative.
## Upgrade guide: Docs/AMBIENT_CHARACTERS.md

const _Pools = preload("res://scripts/npc/AmbientDialoguePools.gd")

@export var speaker_name: String = "Worker"
@export var lines: PackedStringArray = []
@export var dialogue_panel_path: NodePath = NodePath("")

var _armed: bool = true
var _busy: bool = false
var _player_inside: bool = false
var _last_line_index: int = -1


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	_disable_parent_interactable()
	if lines.is_empty():
		lines = _Pools.default_for_speaker(speaker_name)


func _disable_parent_interactable() -> void:
	var parent_npc := get_parent()
	if parent_npc == null:
		return
	if "can_interact" in parent_npc:
		parent_npc.can_interact = false
	var legacy := parent_npc.get_node_or_null("Interactable")
	if legacy:
		if "enabled" in legacy:
			legacy.enabled = false
		legacy.monitoring = false


func _on_body_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	_player_inside = true
	if not _armed or _busy:
		return
	if lines.is_empty():
		return
	if _systems_busy():
		return
	_armed = false
	await _run_line(body)


func _on_body_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	_player_inside = false
	if not _busy:
		_armed = true


func _systems_busy() -> bool:
	var dialogue := _get_dialogue()
	if dialogue == null:
		return true
	if dialogue.visible:
		return true
	var scene := get_tree().current_scene
	if scene:
		var quiz := scene.get_node_or_null("QuizPanel")
		if quiz and quiz.visible:
			return true
	return false


func _get_dialogue() -> CanvasLayer:
	if not dialogue_panel_path.is_empty():
		var n := get_node_or_null(dialogue_panel_path)
		if n is CanvasLayer:
			return n as CanvasLayer
	var scene := get_tree().current_scene
	if scene:
		var d := scene.get_node_or_null("DialoguePanel")
		if d is CanvasLayer:
			return d as CanvasLayer
	return null


func _pick_line() -> String:
	if lines.is_empty():
		return ""
	if lines.size() == 1:
		_last_line_index = 0
		return lines[0]
	var idx := randi() % lines.size()
	if idx == _last_line_index:
		idx = (_last_line_index + 1 + randi() % (lines.size() - 1)) % lines.size()
	_last_line_index = idx
	return lines[idx]


func _run_line(player: Node) -> void:
	_busy = true
	var dialogue := _get_dialogue()
	if dialogue == null or not dialogue.has_method("show_line"):
		_busy = false
		if not _player_inside:
			_armed = true
		return
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(true)
	var text := _pick_line()
	dialogue.show_line(speaker_name, text)
	if dialogue.has_signal("line_finished"):
		await dialogue.line_finished
	if dialogue.has_method("hide_dialogue"):
		dialogue.hide_dialogue()
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(false)
	_busy = false
	if not _player_inside:
		_armed = true

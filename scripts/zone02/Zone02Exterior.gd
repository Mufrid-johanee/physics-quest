extends Node2D
## Zone 02 Energy Assessment Wing — Exterior.
## Scene tree owns all layout transforms. Runtime does not overwrite them.
## Door1 → Floor1. Door2 unlocks after zone02_floor1_passed → Floor2.
## Door3 unlocks after zone02_floor2_passed → Floor3.
## Lock state is monotonic: once unlocked, a door never locks again this session.

const FLOOR1_PATH := "res://scenes/zone02/Zone02_Floor1.tscn"
const FLOOR2_PATH := "res://scenes/zone02/Zone02_Floor2.tscn"
const FLOOR3_PATH := "res://scenes/zone02/Zone02_Floor3.tscn"

const GUIDE_LINES: PackedStringArray = [
	"Welcome to the Energy Assessment Wing.",
	"Door 1 is your first assessment area — the others stay locked for now.",
	"Head through Door 1 when you're ready.",
]

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var guide: CharacterBody2D = $NPCs/Guide
@onready var guide_area: Area2D = $NPCs/Guide/InteractionArea
@onready var door1: Area2D = $Doors/Door1
@onready var door2: Area2D = $Doors/Door2
@onready var door3: Area2D = $Doors/Door3
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var prompt_label: Label = $UI/PromptLabel

var _door1_available: bool = true
var _door2_locked: bool = true
var _door3_locked: bool = true

var _guide_busy: bool = false
var _guide_armed: bool = true


func _ready() -> void:
	_apply_door_lock_state()
	_place_player_at_entry_spawn()

	if player.has_method("set_seated"):
		player.set_seated(false)
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(false)

	if prompt_label:
		prompt_label.visible = false

	if guide and "can_interact" in guide:
		guide.can_interact = false
	if guide:
		var legacy := guide.get_node_or_null("Interactable")
		if legacy and "enabled" in legacy:
			legacy.enabled = false
		if legacy:
			legacy.monitoring = false

	if guide_area:
		if not guide_area.body_entered.is_connected(_on_guide_area_entered):
			guide_area.body_entered.connect(_on_guide_area_entered)
		if not guide_area.body_exited.is_connected(_on_guide_area_exited):
			guide_area.body_exited.connect(_on_guide_area_exited)

	_wire_door(door1, _on_door1_entered, _on_door_exited, _on_door1_interacted)
	_wire_door(door2, _on_door2_entered, _on_door_exited, _on_door2_interacted)
	_wire_door(door3, _on_door3_entered, _on_door_exited, _on_door3_interacted)


func _apply_door_lock_state() -> void:
	## Monotonic unlock from progression flags. Later floors imply earlier doors stay open.
	_door1_available = true
	var door2_unlocked := (
		GameState.zone02_floor1_passed
		or GameState.zone02_floor2_passed
		or GameState.zone02_floor3_passed
		or GameState.zone02_floor4_passed
		or GameState.zone02_complete
	)
	var door3_unlocked := (
		GameState.zone02_floor2_passed
		or GameState.zone02_floor3_passed
		or GameState.zone02_floor4_passed
		or GameState.zone02_complete
	)
	_door2_locked = not door2_unlocked
	_door3_locked = not door3_unlocked
	var door2_locked_visual: CanvasItem = door2.get_node_or_null("LockedVisual") as CanvasItem if door2 else null
	if door2_locked_visual:
		door2_locked_visual.visible = _door2_locked
	var door3_locked_visual: CanvasItem = door3.get_node_or_null("LockedVisual") as CanvasItem if door3 else null
	if door3_locked_visual:
		door3_locked_visual.visible = _door3_locked


func _place_player_at_entry_spawn() -> void:
	if player == null:
		return
	var marker_name := str(GameState.zone02_exterior_spawn_marker)
	GameState.zone02_exterior_spawn_marker = ""
	if not marker_name.is_empty():
		var marker: Marker2D = get_node_or_null(marker_name) as Marker2D
		if marker:
			player.global_position = marker.global_position
			return
	if player_spawn:
		player.global_position = player_spawn.global_position


func _wire_door(area: Area2D, on_enter: Callable, on_exit: Callable, on_interact: Callable) -> void:
	if area == null:
		return
	if area.has_signal("player_entered"):
		area.player_entered.connect(on_enter)
	if area.has_signal("player_exited"):
		area.player_exited.connect(on_exit)
	if area.has_signal("interacted"):
		area.interacted.connect(on_interact)


func _on_guide_area_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if _guide_busy:
		return
	if not _guide_armed:
		return
	_guide_armed = false
	await _run_guide_dialogue()


func _on_guide_area_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not _guide_busy:
		_guide_armed = true


func _run_guide_dialogue() -> void:
	_guide_busy = true
	if player and player.has_method("set_scripted_control"):
		player.set_scripted_control(true)
	if GameState.zone02_floor3_passed:
		await _show_line("Rina", "Door 3 is done. Floor 4 is next when you're ready.")
	elif GameState.zone02_floor2_passed:
		await _show_line("Rina", "Door 2 is done. Door 3 is open when you're ready for the next assessment.")
	elif GameState.zone02_floor1_passed:
		await _show_line("Rina", "Door 1 is done. Door 2 is open when you're ready for the next assessment.")
	else:
		for line in GUIDE_LINES:
			await _show_line("Rina", line)
	dialogue.hide_dialogue()
	if player and player.has_method("set_scripted_control"):
		player.set_scripted_control(false)
	_guide_busy = false


func _on_door1_entered(_body: Node) -> void:
	if not _door1_available:
		_show_prompt("Door 1 is not available.")
		return
	_show_prompt("Press E / F — Enter Door 1")


func _on_door1_interacted(_by: Node) -> void:
	if not _door1_available:
		_show_prompt("Door 1 is not available.")
		return
	if not ResourceLoader.exists(FLOOR1_PATH):
		_show_prompt("Door 1 — Floor 1 assessment coming soon.")
		return
	_hide_prompt()
	_go_scene(FLOOR1_PATH)


func _on_door2_entered(_body: Node) -> void:
	if _door2_locked:
		_show_prompt("Door 2 is locked. Complete Door 1 first.")
	else:
		_show_prompt("Press E / F — Enter Door 2")


func _on_door2_interacted(_by: Node) -> void:
	if _door2_locked:
		_show_prompt("Door 2 is locked. Complete Door 1 first.")
		return
	if not ResourceLoader.exists(FLOOR2_PATH):
		_show_prompt("Door 2 unlocked — Floor 2 assessment coming soon.")
		return
	_hide_prompt()
	_go_scene(FLOOR2_PATH)


func _on_door3_entered(_body: Node) -> void:
	if _door3_locked:
		_show_prompt("Door 3 is locked. Complete Door 2 first.")
	else:
		_show_prompt("Press E / F — Enter Door 3")


func _on_door3_interacted(_by: Node) -> void:
	if _door3_locked:
		_show_prompt("Door 3 is locked. Complete Door 2 first.")
		return
	if not ResourceLoader.exists(FLOOR3_PATH):
		_show_prompt("Door 3 unlocked — Floor 3 assessment coming soon.")
		return
	_hide_prompt()
	_go_scene(FLOOR3_PATH)


func _on_door_exited(_body: Node) -> void:
	_hide_prompt()


func _show_prompt(text: String) -> void:
	if prompt_label:
		prompt_label.visible = true
		prompt_label.text = text


func _hide_prompt() -> void:
	if prompt_label:
		prompt_label.visible = false


func _go_scene(path: String) -> void:
	if SceneTransition.is_busy():
		await SceneTransition.transition_finished
	SceneTransition.change_to(path)


func _show_line(speaker: String, text: String) -> void:
	dialogue.show_line(speaker, text)
	await dialogue.line_finished

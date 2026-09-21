extends Node2D
## Zone 04 Floor 3 — Professor Nadia → 10Q / 80% → Exterior (Door 4 unlock).
## Must return to Exterior — do NOT Continue straight to Floor 4.
## Exact approved Nadia dialogue not in repo — minimal lines.

const EXTERIOR_PATH := "res://scenes/zone04/Zone04_Exterior.tscn"

const NADIA_LINES: PackedStringArray = [
	"This is Bay 3 — Ohm's law and circuit reasoning.",
	"I'm Professor Nadia. You'll need at least 80% to pass.",
	"I will assess you on Ohm's law and circuit reasoning using Apply and Analyze level questions — you will need to apply ideas and analyze situations.",
	"Pass to unlock Door 4 on the Substation entry.",
	"The assessment begins now.",
]

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var nadia: CharacterBody2D = $NPCs/Nadia
@onready var nadia_area: Area2D = $NPCs/Nadia/InteractionArea
@onready var exterior_exit: Area2D = $Interactions/ExteriorExit
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var quiz_panel: CanvasLayer = $QuizPanel
@onready var quiz_controller: QuizController = $QuizController
@onready var prompt_label: Label = $UI/PromptLabel

var _talk_busy: bool = false
var _quiz_busy: bool = false
var _armed: bool = true


func _ready() -> void:
	if player_spawn and player:
		player.global_position = player_spawn.global_position
	if player.has_method("set_seated"):
		player.set_seated(false)
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(false)
	if prompt_label:
		prompt_label.visible = false
	_disable_shared_interactable(nadia)
	if quiz_controller and quiz_panel and quiz_panel.has_method("bind_controller"):
		quiz_panel.bind_controller(quiz_controller)
	if quiz_panel:
		if quiz_panel.has_signal("continue_pressed"):
			quiz_panel.continue_pressed.connect(_on_quiz_continue)
		if quiz_panel.has_signal("retry_pressed"):
			quiz_panel.retry_pressed.connect(_on_quiz_retry)
	if nadia_area:
		if not nadia_area.body_entered.is_connected(_on_area_entered):
			nadia_area.body_entered.connect(_on_area_entered)
		if not nadia_area.body_exited.is_connected(_on_area_exited_npc):
			nadia_area.body_exited.connect(_on_area_exited_npc)
	_wire_area(exterior_exit, _on_exterior_entered, _on_exit_exited, _on_exterior_interacted)


func _disable_shared_interactable(npc: Node) -> void:
	if npc and "can_interact" in npc:
		npc.can_interact = false
	if npc:
		var legacy := npc.get_node_or_null("Interactable")
		if legacy and "enabled" in legacy:
			legacy.enabled = false
		if legacy:
			legacy.monitoring = false


func _wire_area(area: Area2D, on_enter: Callable, on_exit: Callable, on_interact: Callable) -> void:
	if area == null:
		return
	if area.has_signal("player_entered"):
		area.player_entered.connect(on_enter)
	if area.has_signal("player_exited"):
		area.player_exited.connect(on_exit)
	if area.has_signal("interacted"):
		area.interacted.connect(on_interact)


func _on_area_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if _talk_busy or _quiz_busy or not _armed:
		return
	_armed = false
	if GameState.zone04_floor3_passed:
		await _run_passed()
		return
	await _run_assessment()


func _on_area_exited_npc(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not _talk_busy and not _quiz_busy:
		_armed = true


func _run_passed() -> void:
	_talk_busy = true
	_set_player_locked(true)
	await _show_line("Professor Nadia", "Assessment already complete. Exit when ready — Door 4 is unlocked.")
	dialogue.hide_dialogue()
	_set_player_locked(false)
	_talk_busy = false


func _run_assessment() -> void:
	_talk_busy = true
	_set_player_locked(true)
	for line in NADIA_LINES:
		await _show_line("Professor Nadia", line)
	dialogue.hide_dialogue()
	_talk_busy = false
	_start_quiz()


func _start_quiz() -> void:
	if quiz_controller == null or quiz_panel == null:
		_set_player_locked(false)
		return
	_quiz_busy = true
	_set_player_locked(true)
	if not quiz_controller.load_zone04_floor3_bank():
		_quiz_busy = false
		_set_player_locked(false)
		_armed = true
		return
	quiz_panel.open_quiz("Zone 04 — Floor 3 Assessment")
	if not quiz_controller.start_quiz():
		quiz_panel.close_quiz()
		_quiz_busy = false
		_set_player_locked(false)
		_armed = true


func _on_quiz_retry() -> void:
	quiz_panel.open_quiz("Zone 04 — Floor 3 Assessment")
	quiz_controller.retry_quiz()


func _on_quiz_continue() -> void:
	GameState.zone04_floor3_passed = true
	if quiz_panel:
		quiz_panel.close_quiz()
	_quiz_busy = false
	_set_player_locked(false)
	_armed = true
	_show_prompt("Door 4 unlocked — exit to the Substation entry when ready.")


func _on_exterior_entered(_body: Node) -> void:
	_show_prompt("Press E / F — Return to Substation Entry")


func _on_exterior_interacted(_by: Node) -> void:
	_hide_prompt()
	GameState.zone04_exterior_spawn_marker = "Floor3ReturnSpawn"
	_go_scene(EXTERIOR_PATH)


func _on_exit_exited(_body: Node) -> void:
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


func _set_player_locked(locked: bool) -> void:
	if player and player.has_method("set_scripted_control"):
		player.set_scripted_control(locked)

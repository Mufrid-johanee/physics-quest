extends Node2D
## Zone 01 Floor 1 — Manager auto-dialogue → 10-question quiz → 80% gate → Floor 2.
## Scene tree owns layout transforms. Runtime does not overwrite them.

const MG1_STUB_PATH := "res://scenes/zone01/MiniGame01_Brake_Stub.tscn"
const FLOOR2_PATH := "res://scenes/zone01/Zone01_Floor2.tscn"
const EXTERIOR_PATH := "res://scenes/zone01/Zone01_Exterior.tscn"

const MANAGER_LINES: PackedStringArray = [
	"Welcome to Floor 1. I'm the Supervisor on this floor.",
	"Your teacher already covered the assessment rules — you need at least 80% to pass.",
	"You'll answer questions on the Floor 1 mechanics concepts you've been studying.",
	"I will assess you on Floor 1 mechanics concepts using Remember and Understand level questions.",
	"Complete this assessment to unlock the stairs to Floor 2.",
	"The assessment begins now.",
]

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var manager: CharacterBody2D = $NPCs/Manager
@onready var manager_area: Area2D = $NPCs/Manager/InteractionArea
@onready var mg1_handoff: Area2D = $Interactions/MG1_Handoff
@onready var floor2_entrance: Area2D = $Interactions/Floor2Entrance
@onready var exterior_exit: Area2D = $Interactions/ExteriorExit
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var quiz_panel: CanvasLayer = $QuizPanel
@onready var quiz_controller: QuizController = $QuizController
@onready var prompt_label: Label = $UI/PromptLabel

var _talk_busy: bool = false
var _quiz_busy: bool = false
var _manager_armed: bool = true


func _ready() -> void:
	if player_spawn and player:
		player.global_position = player_spawn.global_position
	if player.has_method("set_seated"):
		player.set_seated(false)
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(false)

	if prompt_label:
		prompt_label.visible = false

	# Disable E/F interact on Manager; Floor 1 uses auto Area2D entry only.
	if manager and "can_interact" in manager:
		manager.can_interact = false
	if manager:
		var legacy := manager.get_node_or_null("Interactable")
		if legacy and "enabled" in legacy:
			legacy.enabled = false
		if legacy:
			legacy.monitoring = false

	if quiz_controller and quiz_panel and quiz_panel.has_method("bind_controller"):
		quiz_panel.bind_controller(quiz_controller)
	if quiz_panel:
		if quiz_panel.has_signal("continue_pressed"):
			quiz_panel.continue_pressed.connect(_on_quiz_continue)
		if quiz_panel.has_signal("retry_pressed"):
			quiz_panel.retry_pressed.connect(_on_quiz_retry)

	if manager_area:
		if not manager_area.body_entered.is_connected(_on_manager_area_entered):
			manager_area.body_entered.connect(_on_manager_area_entered)
		if not manager_area.body_exited.is_connected(_on_manager_area_exited):
			manager_area.body_exited.connect(_on_manager_area_exited)

	_wire_area(mg1_handoff, _on_mg1_entered, _on_mg1_exited, _on_mg1_interacted)
	_wire_area(floor2_entrance, _on_floor2_entered, _on_area_exited, _on_floor2_interacted)
	_wire_area(exterior_exit, _on_exterior_entered, _on_area_exited, _on_exterior_interacted)


func _wire_area(area: Area2D, on_enter: Callable, on_exit: Callable, on_interact: Callable) -> void:
	if area == null:
		return
	if area.has_signal("player_entered"):
		area.player_entered.connect(on_enter)
	if area.has_signal("player_exited"):
		area.player_exited.connect(on_exit)
	if area.has_signal("interacted"):
		area.interacted.connect(on_interact)


func _on_manager_area_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if _talk_busy or _quiz_busy:
		return
	if not _manager_armed:
		return
	_manager_armed = false
	if GameState.zone01_floor1_passed:
		await _run_already_passed_line()
		return
	await _run_manager_assessment_sequence()


func _on_manager_area_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	# Re-arm only when idle so re-entry can start again after fail/leave.
	if not _talk_busy and not _quiz_busy:
		_manager_armed = true


func _run_already_passed_line() -> void:
	_talk_busy = true
	_set_player_locked(true)
	await _show_line("Supervisor", "Assessment already complete. Take the stairs to Floor 2 when you're ready.")
	dialogue.hide_dialogue()
	_set_player_locked(false)
	_talk_busy = false


func _run_manager_assessment_sequence() -> void:
	_talk_busy = true
	_set_player_locked(true)
	for line in MANAGER_LINES:
		await _show_line("Supervisor", line)
	dialogue.hide_dialogue()
	_talk_busy = false
	_start_quiz()


func _start_quiz() -> void:
	if quiz_controller == null or quiz_panel == null:
		push_error("Floor1: missing QuizController or QuizPanel")
		_set_player_locked(false)
		return
	_quiz_busy = true
	_set_player_locked(true)
	if not quiz_controller.load_floor1_bank():
		push_error("Floor1: failed to load question bank")
		_quiz_busy = false
		_set_player_locked(false)
		_manager_armed = true
		return
	quiz_panel.open_quiz("Floor 1 Assessment")
	if not quiz_controller.start_quiz():
		push_error("Floor1: failed to start quiz")
		quiz_panel.close_quiz()
		_quiz_busy = false
		_set_player_locked(false)
		_manager_armed = true


func _on_quiz_retry() -> void:
	if quiz_controller == null or quiz_panel == null:
		return
	quiz_panel.open_quiz("Floor 1 Assessment")
	if not quiz_controller.retry_quiz():
		push_error("Floor1: retry failed")


func _on_quiz_continue() -> void:
	GameState.zone01_floor1_passed = true
	if quiz_panel:
		quiz_panel.close_quiz()
	_quiz_busy = false
	_set_player_locked(false)
	_manager_armed = true
	_show_prompt("Floor 2 unlocked — walk to the stairs when ready.")


func _on_mg1_entered(_body: Node) -> void:
	_show_prompt("Press E / F — MG1 Emergency Brake (stub / not implemented)")


func _on_mg1_exited(_body: Node) -> void:
	_hide_prompt()


func _on_mg1_interacted(_by: Node) -> void:
	_hide_prompt()
	_go_scene(MG1_STUB_PATH)


func _on_floor2_entered(_body: Node) -> void:
	if GameState.zone01_floor1_passed:
		_show_prompt("Press E / F — Enter Floor 2")
	else:
		_show_prompt("Complete the Floor 1 assessment first.")


func _on_floor2_interacted(_by: Node) -> void:
	if not GameState.zone01_floor1_passed:
		_show_prompt("Complete the Floor 1 assessment first.")
		return
	_hide_prompt()
	_go_scene(FLOOR2_PATH)


func _on_exterior_entered(_body: Node) -> void:
	_show_prompt("Press E / F — Return to Factory Exterior")


func _on_exterior_interacted(_by: Node) -> void:
	_hide_prompt()
	_go_scene(EXTERIOR_PATH)


func _on_area_exited(_body: Node) -> void:
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

extends Node2D
## Zone 02 Floor 3 — Karim auto-dialogue → 10-question quiz → 80% → Floor 4.
## After pass, Continue goes to Floor 4 (not Exterior).
## Scene tree owns layout transforms. Runtime does not overwrite them.
## No mini-games.

const FLOOR4_PATH := "res://scenes/zone02/Zone02_Floor4.tscn"
const EXTERIOR_PATH := "res://scenes/zone02/Zone02_Exterior.tscn"

const KARIM_LINES: PackedStringArray = [
	"This is Floor 3 of the Energy Assessment Wing.",
	"You'll need at least 80% to pass.",
	"Expect applied and analytical questions — some short answers, some multiple choice.",
	"I will assess you on energy and power concepts using Apply and Analyze level questions — you will need to apply ideas and analyze situations.",
	"Pass this assessment to continue to Floor 4.",
	"The assessment begins now.",
]

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var karim: CharacterBody2D = $NPCs/Karim
@onready var karim_area: Area2D = $NPCs/Karim/InteractionArea
@onready var exterior_exit: Area2D = $Interactions/ExteriorExit
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var quiz_panel: CanvasLayer = $QuizPanel
@onready var quiz_controller: QuizController = $QuizController
@onready var prompt_label: Label = $UI/PromptLabel

var _talk_busy: bool = false
var _quiz_busy: bool = false
var _karim_armed: bool = true


func _ready() -> void:
	if player_spawn and player:
		player.global_position = player_spawn.global_position
	if player.has_method("set_seated"):
		player.set_seated(false)
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(false)

	if prompt_label:
		prompt_label.visible = false

	if karim and "can_interact" in karim:
		karim.can_interact = false
	if karim:
		var legacy := karim.get_node_or_null("Interactable")
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
		_set_continue_button_label("Continue to Floor 4")

	if karim_area:
		if not karim_area.body_entered.is_connected(_on_karim_area_entered):
			karim_area.body_entered.connect(_on_karim_area_entered)
		if not karim_area.body_exited.is_connected(_on_karim_area_exited):
			karim_area.body_exited.connect(_on_karim_area_exited)

	_wire_area(exterior_exit, _on_exterior_entered, _on_area_exited, _on_exterior_interacted)


func _set_continue_button_label(text: String) -> void:
	if quiz_panel == null:
		return
	var btn: Button = quiz_panel.get_node_or_null("Root/Center/ResultPanel/Margin/VBox/Buttons/ContinueButton") as Button
	if btn:
		btn.text = text


func _wire_area(area: Area2D, on_enter: Callable, on_exit: Callable, on_interact: Callable) -> void:
	if area == null:
		return
	if area.has_signal("player_entered"):
		area.player_entered.connect(on_enter)
	if area.has_signal("player_exited"):
		area.player_exited.connect(on_exit)
	if area.has_signal("interacted"):
		area.interacted.connect(on_interact)


func _on_karim_area_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if _talk_busy or _quiz_busy:
		return
	if not _karim_armed:
		return
	_karim_armed = false
	if GameState.zone02_floor3_passed:
		await _run_already_passed_line()
		return
	await _run_karim_assessment_sequence()


func _on_karim_area_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not _talk_busy and not _quiz_busy:
		_karim_armed = true


func _run_already_passed_line() -> void:
	_talk_busy = true
	_set_player_locked(true)
	await _show_line("Karim", "Assessment already complete. Continue to Floor 4 when you're ready.")
	dialogue.hide_dialogue()
	_set_player_locked(false)
	_talk_busy = false
	_go_to_floor4_or_prompt()


func _run_karim_assessment_sequence() -> void:
	_talk_busy = true
	_set_player_locked(true)
	for line in KARIM_LINES:
		await _show_line("Karim", line)
	dialogue.hide_dialogue()
	_talk_busy = false
	_start_quiz()


func _start_quiz() -> void:
	if quiz_controller == null or quiz_panel == null:
		push_error("Zone02Floor3: missing QuizController or QuizPanel")
		_set_player_locked(false)
		return
	_quiz_busy = true
	_set_player_locked(true)
	if not quiz_controller.load_zone02_floor3_bank():
		push_error("Zone02Floor3: failed to load question bank")
		_quiz_busy = false
		_set_player_locked(false)
		_karim_armed = true
		return
	quiz_panel.open_quiz("Zone 02 — Floor 3 Assessment")
	if not quiz_controller.start_quiz():
		push_error("Zone02Floor3: failed to start quiz")
		quiz_panel.close_quiz()
		_quiz_busy = false
		_set_player_locked(false)
		_karim_armed = true


func _on_quiz_retry() -> void:
	if quiz_controller == null or quiz_panel == null:
		return
	quiz_panel.open_quiz("Zone 02 — Floor 3 Assessment")
	if not quiz_controller.retry_quiz():
		push_error("Zone02Floor3: retry failed")


func _on_quiz_continue() -> void:
	## Pass only: set flag and go to Floor 4. Never return to Exterior here.
	GameState.zone02_floor3_passed = true
	if quiz_panel:
		quiz_panel.close_quiz()
	_quiz_busy = false
	_set_player_locked(false)
	_karim_armed = true
	_go_to_floor4_or_prompt()


func _go_to_floor4_or_prompt() -> void:
	if ResourceLoader.exists(FLOOR4_PATH):
		_go_scene(FLOOR4_PATH)
	else:
		_show_prompt("Floor 4 coming soon — next implementation phase.")


func _on_exterior_entered(_body: Node) -> void:
	_show_prompt("Press E / F — Return to Energy Assessment Wing")


func _on_exterior_interacted(_by: Node) -> void:
	## Voluntary leave only (not the pass Continue path).
	_hide_prompt()
	GameState.zone02_exterior_spawn_marker = "Floor3ReturnSpawn"
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

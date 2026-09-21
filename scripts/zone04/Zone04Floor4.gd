extends Node2D
## Zone 04 Floor 4 — Farid assessment → ONE mini-game PLACEHOLDER → SUCCESSFUL → unlock Zone 05.
## Floors 1–3 / Exterior / Door progression unchanged. Scene tree owns layout transforms.

const EXTERIOR_PATH := "res://scenes/zone04/Zone04_Exterior.tscn"
const WORLD_MAP_PATH := "res://scenes/world_map/WorldMap.tscn"

const FARID_LINES: PackedStringArray = [
	"This is the final bay of the Substation.",
	"I'm Engineer Farid. You'll need at least 80% to pass.",
	"These questions test analysis and evaluation.",
	"I will assess you on electricity and magnetism diagnostics using Analyze and Evaluate level questions.",
	"Pass this assessment, then visit the Mini-Game Area placeholder.",
	"The final assessment begins now.",
]

const CREATE_MINIGAME_LINE := "After this assessment, your next challenge will be a mini-game based on the Create level, where you will need to use what you have learned to create or construct something."

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var farid: CharacterBody2D = $NPCs/Farid
@onready var farid_area: Area2D = $NPCs/Farid/InteractionArea
@onready var mini_game_area: Area2D = $MiniGameArea
@onready var exterior_exit: Area2D = $Interactions/ExteriorExit
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var quiz_panel: CanvasLayer = $QuizPanel
@onready var quiz_controller: QuizController = $QuizController
@onready var prompt_label: Label = $UI/PromptLabel
@onready var demo_panel: Control = $DemoCompleteUI/Root
@onready var placeholder_label: Label = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/BadgeLabel
@onready var play_mg1_btn: Button = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame1Button
@onready var play_mg2_btn: Button = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame2Button
@onready var close_placeholder_btn: Button = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/ClosePlaceholderButton
@onready var return_wm_btn: Button = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/ReturnToWorldMapButton

var _talk_busy: bool = false
var _quiz_busy: bool = false
var _armed: bool = true
var _mg_armed: bool = true
var _placeholder_open: bool = false


func _ready() -> void:
	if player_spawn and player:
		player.global_position = player_spawn.global_position
	if player.has_method("set_seated"):
		player.set_seated(false)
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(false)
	if prompt_label:
		prompt_label.visible = false
	if demo_panel:
		demo_panel.visible = false
	_hide_unused_ui_nodes()
	_disable_shared_interactable(farid)
	if quiz_controller and quiz_panel and quiz_panel.has_method("bind_controller"):
		quiz_panel.bind_controller(quiz_controller)
	if quiz_panel:
		if quiz_panel.has_signal("continue_pressed"):
			quiz_panel.continue_pressed.connect(_on_quiz_continue)
		if quiz_panel.has_signal("retry_pressed"):
			quiz_panel.retry_pressed.connect(_on_quiz_retry)
		_set_continue_button_label("Continue")
	if farid_area:
		if not farid_area.body_entered.is_connected(_on_farid_entered):
			farid_area.body_entered.connect(_on_farid_entered)
		if not farid_area.body_exited.is_connected(_on_farid_exited):
			farid_area.body_exited.connect(_on_farid_exited)
	if mini_game_area:
		mini_game_area.monitoring = GameState.zone04_floor4_passed
		if not mini_game_area.body_entered.is_connected(_on_mg_entered):
			mini_game_area.body_entered.connect(_on_mg_entered)
		if not mini_game_area.body_exited.is_connected(_on_mg_exited):
			mini_game_area.body_exited.connect(_on_mg_exited)
	_wire_placeholder_buttons()
	_wire_area(exterior_exit, _on_exterior_entered, _on_exit_exited, _on_exterior_interacted)


func _hide_unused_ui_nodes() -> void:
	for path in [
		"DemoCompleteUI/Root/Center/Panel/Margin/VBox/CompleteButton",
		"DemoCompleteUI/Root/Center/Panel/Margin/VBox/BadgeArt",
	]:
		var n: CanvasItem = get_node_or_null(path) as CanvasItem
		if n:
			n.visible = false
	if play_mg2_btn:
		play_mg2_btn.visible = false
	if close_placeholder_btn:
		close_placeholder_btn.visible = false


func _wire_placeholder_buttons() -> void:
	if play_mg1_btn and not play_mg1_btn.pressed.is_connected(_on_play_mg1):
		play_mg1_btn.pressed.connect(_on_play_mg1)
	if return_wm_btn and not return_wm_btn.pressed.is_connected(_on_return_world_map):
		return_wm_btn.pressed.connect(_on_return_world_map)


func _set_continue_button_label(text: String) -> void:
	if quiz_panel == null:
		return
	var btn: Button = quiz_panel.get_node_or_null("Root/Center/ResultPanel/Margin/VBox/Buttons/ContinueButton") as Button
	if btn:
		btn.text = text


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


func _on_farid_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if _talk_busy or _quiz_busy or _placeholder_open or not _armed:
		return
	_armed = false
	if GameState.zone04_floor4_passed:
		await _run_passed()
		return
	await _run_assessment()


func _on_farid_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not _talk_busy and not _quiz_busy and not _placeholder_open:
		_armed = true


func _run_passed() -> void:
	_talk_busy = true
	_set_player_locked(true)
	if GameState.zone04_minigame_successful:
		await _show_line("Engineer Farid", "Zone 04 is complete. Return to the World Map when ready.")
	else:
		await _show_line("Engineer Farid", "Final assessment already complete. Enter the Mini-Game Area when ready.")
		await _show_line("Engineer Farid", CREATE_MINIGAME_LINE)
	dialogue.hide_dialogue()
	_set_player_locked(false)
	_talk_busy = false
	if not GameState.zone04_minigame_successful:
		_show_prompt("Enter Mini-Game Area — PLAY MINI-GAME 1")


func _run_assessment() -> void:
	_talk_busy = true
	_set_player_locked(true)
	for line in FARID_LINES:
		await _show_line("Engineer Farid", line)
	dialogue.hide_dialogue()
	_talk_busy = false
	_start_quiz()


func _start_quiz() -> void:
	if quiz_controller == null or quiz_panel == null:
		_set_player_locked(false)
		return
	_quiz_busy = true
	_set_player_locked(true)
	if not quiz_controller.load_zone04_floor4_bank():
		_quiz_busy = false
		_set_player_locked(false)
		_armed = true
		return
	quiz_panel.open_quiz("Zone 04 — Final Assessment")
	if not quiz_controller.start_quiz():
		quiz_panel.close_quiz()
		_quiz_busy = false
		_set_player_locked(false)
		_armed = true


func _on_quiz_retry() -> void:
	quiz_panel.open_quiz("Zone 04 — Final Assessment")
	quiz_controller.retry_quiz()


func _on_quiz_continue() -> void:
	GameState.zone04_floor4_passed = true
	if quiz_panel:
		quiz_panel.close_quiz()
	_quiz_busy = false
	_talk_busy = true
	_set_player_locked(true)
	await _show_line("Engineer Farid", CREATE_MINIGAME_LINE)
	dialogue.hide_dialogue()
	_talk_busy = false
	_set_player_locked(false)
	_armed = true
	if mini_game_area:
		mini_game_area.monitoring = true
	_open_placeholder_ui()


func _on_mg_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not GameState.zone04_floor4_passed:
		return
	if _placeholder_open or not _mg_armed:
		return
	_mg_armed = false
	_open_placeholder_ui()


func _on_mg_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not _placeholder_open:
		_mg_armed = true


func _open_placeholder_ui() -> void:
	_placeholder_open = true
	_set_player_locked(true)
	_hide_prompt()
	_hide_unused_ui_nodes()
	if GameState.zone04_minigame_successful:
		_show_successful_ui()
	else:
		if placeholder_label:
			placeholder_label.text = "MINI-GAME 04 PLACEHOLDER\nReal mini-game deferred.\nPress PLAY MINI-GAME 1."
		if play_mg1_btn:
			play_mg1_btn.visible = true
			play_mg1_btn.text = "PLAY MINI-GAME 1"
		if return_wm_btn:
			return_wm_btn.visible = false
	if demo_panel:
		demo_panel.visible = true


func _on_play_mg1() -> void:
	GameState.mark_minigame_successful(GameState.ZONE_04)
	_show_successful_ui()


func _show_successful_ui() -> void:
	if placeholder_label:
		placeholder_label.text = "SUCCESSFUL\nZone 05 unlocked on the World Map."
	if play_mg1_btn:
		play_mg1_btn.visible = false
	if play_mg2_btn:
		play_mg2_btn.visible = false
	if close_placeholder_btn:
		close_placeholder_btn.visible = false
	if return_wm_btn:
		return_wm_btn.visible = true
		return_wm_btn.text = "RETURN TO THE WORLD MAP"


func _on_return_world_map() -> void:
	_go_scene(WORLD_MAP_PATH)


func _on_exterior_entered(_body: Node) -> void:
	_show_prompt("Press E / F — Return to Substation Entry")


func _on_exterior_interacted(_by: Node) -> void:
	_hide_prompt()
	GameState.zone04_exterior_spawn_marker = "Floor4ReturnSpawn"
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

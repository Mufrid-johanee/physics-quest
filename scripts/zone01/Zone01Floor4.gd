extends Node2D
## Zone 01 Floor 4 — Director assessment → Emergency Brake mini-game → unlock Zone 02.
## Floor 1–3 unchanged. Scene tree owns layout transforms.

const FLOOR3_PATH := "res://scenes/zone01/Zone01_Floor3.tscn"
const WORLD_MAP_PATH := "res://scenes/world_map/WorldMap.tscn"
const MG1_PATH := "res://scenes/minigames/zone01/MiniGame01_Brake.tscn"

const DIRECTOR_LINES: PackedStringArray = [
	"You've reached Floor 4 — my office. I'm the Director.",
	"Your teacher already covered the assessment rules — you need at least 80% to pass.",
	"This is the final Floor 4 assessment before later factory challenges.",
	"I will assess you on Floor 4 mechanics using Analyze and Evaluate level questions.",
	"Answer carefully. Pass this assessment to complete the Director evaluation.",
	"The assessment begins now.",
]

const CREATE_MINIGAME_LINE := "After this assessment, your next challenge will be a mini-game based on the Create level, where you will need to use what you have learned to create or construct something."

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var director: CharacterBody2D = $NPCs/Director
@onready var director_area: Area2D = $NPCs/Director/InteractionArea
@onready var floor3_entrance: Area2D = $Interactions/Floor3Entrance
@onready var mini_game_handoff: Area2D = $Interactions/MiniGameHandoff
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var quiz_panel: CanvasLayer = $QuizPanel
@onready var quiz_controller: QuizController = $QuizController
@onready var prompt_label: Label = $UI/PromptLabel
@onready var demo_panel: Control = $DemoCompleteUI/Root
@onready var placeholder_label: Label = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/BadgeLabel
@onready var play_mg1_btn: Button = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame1Button
@onready var return_wm_btn: Button = $DemoCompleteUI/Root/Center/Panel/Margin/VBox/ReturnToWorldMapButton

var _talk_busy: bool = false
var _quiz_busy: bool = false
var _director_armed: bool = true
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

	if director and "can_interact" in director:
		director.can_interact = false
	if director:
		var legacy := director.get_node_or_null("Interactable")
		if legacy and "enabled" in legacy:
			legacy.enabled = false
		if legacy:
			legacy.monitoring = false

	var legacy_dir_area := get_node_or_null("Interactions/director interaction") as Area2D
	if legacy_dir_area:
		legacy_dir_area.monitoring = false
		legacy_dir_area.monitorable = false

	if quiz_controller and quiz_panel and quiz_panel.has_method("bind_controller"):
		quiz_panel.bind_controller(quiz_controller)
	if quiz_panel:
		if quiz_panel.has_signal("continue_pressed"):
			quiz_panel.continue_pressed.connect(_on_quiz_continue)
		if quiz_panel.has_signal("retry_pressed"):
			quiz_panel.retry_pressed.connect(_on_quiz_retry)

	if director_area:
		if not director_area.body_entered.is_connected(_on_director_area_entered):
			director_area.body_entered.connect(_on_director_area_entered)
		if not director_area.body_exited.is_connected(_on_director_area_exited):
			director_area.body_exited.connect(_on_director_area_exited)

	_wire_area(floor3_entrance, _on_floor3_entered, _on_area_exited, _on_floor3_interacted)
	_wire_mg_handoff()
	_wire_placeholder_buttons()


func _hide_unused_ui_nodes() -> void:
	for path in [
		"DemoCompleteUI/Root/Center/Panel/Margin/VBox/CompleteButton",
		"DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame2Button",
		"DemoCompleteUI/Root/Center/Panel/Margin/VBox/ClosePlaceholderButton",
		"DemoCompleteUI/Root/Center/Panel/Margin/VBox/BadgeArt",
	]:
		var n: CanvasItem = get_node_or_null(path) as CanvasItem
		if n:
			n.visible = false


func _wire_mg_handoff() -> void:
	if mini_game_handoff == null:
		return
	if "enabled" in mini_game_handoff:
		mini_game_handoff.enabled = GameState.zone01_floor4_passed
	mini_game_handoff.monitoring = GameState.zone01_floor4_passed
	if not mini_game_handoff.body_entered.is_connected(_on_mg_body_entered):
		mini_game_handoff.body_entered.connect(_on_mg_body_entered)
	if not mini_game_handoff.body_exited.is_connected(_on_mg_body_exited):
		mini_game_handoff.body_exited.connect(_on_mg_body_exited)
	_wire_area(mini_game_handoff, _on_mg_entered_prompt, _on_area_exited, _on_mg_interacted)


func _wire_placeholder_buttons() -> void:
	if play_mg1_btn and not play_mg1_btn.pressed.is_connected(_on_play_mg1):
		play_mg1_btn.pressed.connect(_on_play_mg1)
	if return_wm_btn and not return_wm_btn.pressed.is_connected(_on_return_world_map):
		return_wm_btn.pressed.connect(_on_return_world_map)


func _wire_area(area: Area2D, on_enter: Callable, on_exit: Callable, on_interact: Callable) -> void:
	if area == null:
		return
	if area.has_signal("player_entered"):
		area.player_entered.connect(on_enter)
	if area.has_signal("player_exited"):
		area.player_exited.connect(on_exit)
	if area.has_signal("interacted"):
		area.interacted.connect(on_interact)


func _on_director_area_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if _talk_busy or _quiz_busy or _placeholder_open:
		return
	if not _director_armed:
		return
	_director_armed = false
	if GameState.zone01_floor4_passed:
		await _run_already_passed_line()
		return
	await _run_director_assessment_sequence()


func _on_director_area_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not _talk_busy and not _quiz_busy and not _placeholder_open:
		_director_armed = true


func _run_already_passed_line() -> void:
	_talk_busy = true
	_set_player_locked(true)
	if GameState.zone01_minigame_successful:
		await _show_line("Director", "Zone 01 is complete. Return to the World Map when ready.")
	else:
		await _show_line("Director", "Assessment complete. Enter the Mini-Game Area when ready.")
		await _show_line("Director", CREATE_MINIGAME_LINE)
	dialogue.hide_dialogue()
	_set_player_locked(false)
	_talk_busy = false
	if not GameState.zone01_minigame_successful:
		_show_prompt("Enter Mini-Game Area — PLAY MINI-GAME 1")


func _run_director_assessment_sequence() -> void:
	_talk_busy = true
	_set_player_locked(true)
	for line in DIRECTOR_LINES:
		await _show_line("Director", line)
	dialogue.hide_dialogue()
	_talk_busy = false
	_start_quiz()


func _start_quiz() -> void:
	if quiz_controller == null or quiz_panel == null:
		_set_player_locked(false)
		return
	_quiz_busy = true
	_set_player_locked(true)
	if not quiz_controller.load_floor4_bank():
		_quiz_busy = false
		_set_player_locked(false)
		_director_armed = true
		return
	quiz_panel.open_quiz("Floor 4 Director Assessment")
	if not quiz_controller.start_quiz():
		quiz_panel.close_quiz()
		_quiz_busy = false
		_set_player_locked(false)
		_director_armed = true


func _on_quiz_retry() -> void:
	quiz_panel.open_quiz("Floor 4 Director Assessment")
	quiz_controller.retry_quiz()


func _on_quiz_continue() -> void:
	GameState.zone01_floor4_passed = true
	if quiz_panel:
		quiz_panel.close_quiz()
	_quiz_busy = false
	_talk_busy = true
	_set_player_locked(true)
	await _show_line("Director", CREATE_MINIGAME_LINE)
	dialogue.hide_dialogue()
	_talk_busy = false
	_set_player_locked(false)
	_director_armed = true
	if mini_game_handoff:
		if "enabled" in mini_game_handoff:
			mini_game_handoff.enabled = true
		mini_game_handoff.monitoring = true
	_open_placeholder_ui()


func _on_mg_body_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not GameState.zone01_floor4_passed:
		return
	if _placeholder_open or not _mg_armed:
		return
	_mg_armed = false
	_open_placeholder_ui()


func _on_mg_body_exited(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if not _placeholder_open:
		_mg_armed = true


func _on_mg_entered_prompt(_body: Node) -> void:
	if GameState.zone01_floor4_passed and not GameState.zone01_minigame_successful:
		_show_prompt("Press E / F — Mini-Game Area")


func _on_mg_interacted(_by: Node) -> void:
	if not GameState.zone01_floor4_passed:
		_show_prompt("Complete the Floor 4 assessment first.")
		return
	_open_placeholder_ui()


func _open_placeholder_ui() -> void:
	_placeholder_open = true
	_set_player_locked(true)
	_hide_prompt()
	_hide_unused_ui_nodes()
	if GameState.zone01_minigame_successful:
		_show_successful_ui()
	else:
		if placeholder_label:
			placeholder_label.text = "EMERGENCY BRAKE\nFriction challenge — Create level.\nPress PLAY MINI-GAME 1."
		if play_mg1_btn:
			play_mg1_btn.visible = true
			play_mg1_btn.text = "PLAY MINI-GAME 1"
		if return_wm_btn:
			return_wm_btn.visible = false
	if demo_panel:
		demo_panel.visible = true


func _on_play_mg1() -> void:
	## Launch real Emergency Brake — success is decided inside the mini-game.
	if GameState.zone01_minigame_successful:
		_show_successful_ui()
		return
	_go_scene(MG1_PATH)


func _show_successful_ui() -> void:
	if placeholder_label:
		placeholder_label.text = "Emergency Brake cleared.\nZone 02 unlocked on the World Map."
	if play_mg1_btn:
		play_mg1_btn.visible = false
	if return_wm_btn:
		return_wm_btn.visible = true
		return_wm_btn.text = "RETURN TO THE WORLD MAP"


func _on_return_world_map() -> void:
	_go_scene(WORLD_MAP_PATH)


func _on_floor3_entered(_body: Node) -> void:
	_show_prompt("Press E / F — Return to Floor 3")


func _on_floor3_interacted(_by: Node) -> void:
	_hide_prompt()
	_go_scene(FLOOR3_PATH)


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

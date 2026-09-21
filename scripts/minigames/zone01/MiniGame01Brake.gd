extends Control
## Zone 01 Emergency Brake - self-contained mini-game (current project architecture).
## Assets: res://asset/minigame asset/zone 1 mini game/mini game 1 asset/
## Data: res://data/zone01_minigames.json

const DATA_PATH := "res://data/zone01_minigames.json"
const WORLD_MAP_PATH := "res://scenes/world_map/WorldMap.tscn"
const ASSET_DIR := "res://asset/minigame asset/zone 1 mini game/mini game 1 asset/"
const G := 10.0

@export var block_start_x: float = 180.0
@export var crash_x: float = 980.0
@export var burst_hframes: int = 6
@export var burst_vframes: int = 1
@export var block_y: float = 420.0

@onready var block: Sprite2D = $BlockSprite
@onready var burst: Sprite2D = $CrashBurst
@onready var info_label: Label = $HUD/InfoLabel
@onready var question_label: Label = $HUD/QuestionLabel
@onready var timer_bar: TextureProgressBar = $HUD/CountdownBar
@onready var yes_btn: TextureButton = $HUD/YesButton
@onready var no_btn: TextureButton = $HUD/NoButton
@onready var force_box: HBoxContainer = $HUD/ForceBox
@onready var ref_card: TextureRect = $HUD/ReferenceCard
@onready var ref_toggle: Button = $HUD/ReferenceToggle
@onready var result_label: Label = $HUD/ResultLabel
@onready var game_over_layer: CanvasLayer = $GameOverLayer
@onready var game_over_label: Label = $GameOverLayer/Center/VBox/GameOverLabel

static var _last_id: String = ""

var scenario: Dictionary = {}
var total_time: float = 12.0
var time_left: float = 12.0
var locked: bool = false
var is_active: bool = false


func _ready() -> void:
	burst.hframes = burst_hframes
	burst.vframes = burst_vframes
	burst.visible = false
	ref_card.visible = false
	force_box.visible = false
	result_label.text = ""
	if game_over_layer:
		game_over_layer.visible = false

	_style_button(yes_btn)
	_style_button(no_btn)
	yes_btn.pressed.connect(_on_answer.bind("yes"))
	no_btn.pressed.connect(_on_answer.bind("no"))

	for child in force_box.get_children():
		var b := child as TextureButton
		if b == null:
			continue
		_style_button(b)
		b.pressed.connect(_on_force_pressed.bind(b))

	ref_toggle.pressed.connect(_on_ref_toggle)
	_start_round()


func _on_ref_toggle() -> void:
	ref_card.visible = not ref_card.visible


func _style_button(b: BaseButton) -> void:
	if b == null:
		return
	b.mouse_entered.connect(func(): if not locked: b.modulate = Color(1.2, 1.2, 1.2))
	b.mouse_exited.connect(func(): b.modulate = Color.WHITE)
	b.button_down.connect(func(): b.modulate = Color(0.75, 0.75, 0.75))
	b.button_up.connect(func(): b.modulate = Color(1.2, 1.2, 1.2))


func _start_round() -> void:
	if game_over_layer:
		game_over_layer.visible = false
	_load_scenario()
	is_active = true


func _load_scenario() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_error("MiniGame01Brake: missing data at %s" % DATA_PATH)
		return
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("MiniGame01Brake: cannot open %s" % DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("MiniGame01Brake: invalid JSON")
		return
	var data: Dictionary = parsed
	var mg: Dictionary = data.get("minigames", {}).get("mg01_brake", {})
	if mg.is_empty():
		push_error("MiniGame01Brake: mg01_brake missing in JSON")
		return

	var pool: Array = mg["yes_scenarios"] if randf() < 0.5 else mg["no_scenarios"]
	var pick: Dictionary = pool.pick_random()
	var tries := 0
	while str(pick.get("id", "")) == _last_id and tries < 10:
		pick = pool.pick_random()
		tries += 1
	scenario = pick
	_last_id = str(pick.get("id", ""))

	total_time = float(scenario.get("countdown_seconds", 12))
	time_left = total_time
	locked = false

	info_label.text = "%s\nMass: %d kg    μ = %.2f\nBraking force needed: %d N" % [
		str(scenario.get("surface_label", "")),
		int(scenario.get("block_mass_kg", 0)),
		float(scenario.get("mu", 0.0)),
		int(scenario.get("required_stop_force_n", 0)),
	]
	question_label.text = "Will friction alone stop the block?"
	result_label.text = ""
	result_label.modulate = Color.WHITE

	block.visible = true
	block.position = Vector2(block_start_x, block_y)
	burst.visible = false
	force_box.visible = false
	yes_btn.visible = true
	no_btn.visible = true
	yes_btn.modulate = Color.WHITE
	no_btn.modulate = Color.WHITE
	timer_bar.value = 100.0


func _process(delta: float) -> void:
	if not is_active or locked:
		return
	time_left -= delta
	var ratio: float = clampf(time_left / total_time, 0.0, 1.0)
	timer_bar.value = ratio * 100.0
	block.position.x = lerpf(crash_x, block_start_x, ratio)
	if time_left <= 0.0:
		_crash("TIME'S UP")


func _on_answer(choice: String) -> void:
	if locked:
		return
	var friction_ok: bool = bool(scenario.get("friction_sufficient", false))
	if choice == "yes":
		if friction_ok:
			_success()
		else:
			_crash("NOT ENOUGH FRICTION")
	else:
		if friction_ok:
			_crash("FRICTION WAS ENOUGH")
		else:
			_show_force_options()


func _show_force_options() -> void:
	yes_btn.visible = false
	no_btn.visible = false
	question_label.text = "How much extra braking force is needed?"

	var values: Array = [int(scenario.get("correct_additional_force_n", 0))]
	var distractors: Array = scenario.get("distractor_forces_n", [])
	for d in distractors:
		values.append(int(d))
	values.shuffle()

	var i := 0
	for child in force_box.get_children():
		var b := child as TextureButton
		if b == null:
			continue
		if i >= values.size():
			b.visible = false
			continue
		b.visible = true
		b.set_meta("force", values[i])
		var lbl: Label = b.get_node_or_null("Label") as Label
		if lbl:
			lbl.text = "%d N" % int(values[i])
		b.modulate = Color.WHITE
		i += 1
	force_box.visible = true


func _on_force_pressed(b: TextureButton) -> void:
	if locked:
		return
	if int(b.get_meta("force")) == int(scenario.get("correct_additional_force_n", -1)):
		_success()
	else:
		_crash("WRONG FORCE")


func _success() -> void:
	locked = true
	is_active = false
	force_box.visible = false
	yes_btn.visible = false
	no_btn.visible = false
	result_label.text = "BLOCK STOPPED"
	result_label.modulate = Color(0.4, 1.0, 0.4)
	var t := create_tween()
	t.tween_property(block, "position:x", block.position.x + 40.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(1.3).timeout
	_on_pass()


func _crash(reason: String) -> void:
	locked = true
	is_active = false
	force_box.visible = false
	yes_btn.visible = false
	no_btn.visible = false
	result_label.text = reason
	result_label.modulate = Color(1.0, 0.35, 0.35)

	var t := create_tween()
	t.tween_property(block, "position:x", crash_x, 0.25)
	await t.finished

	burst.position = block.position
	burst.frame = 0
	burst.visible = true
	var frames := burst_hframes * burst_vframes
	var bt := create_tween()
	bt.tween_property(burst, "frame", maxi(frames - 1, 0), 0.7)
	await bt.finished

	block.visible = false
	await get_tree().create_timer(0.8).timeout
	_on_fail()


func _on_pass() -> void:
	## Current project: one Zone 01 mini-game → mark success → World Map (not obsolete MG2 sequence).
	GameState.mark_minigame_successful(GameState.ZONE_01)
	if SceneTransition.is_busy():
		await SceneTransition.transition_finished
	SceneTransition.change_to(WORLD_MAP_PATH)


func _on_fail() -> void:
	if game_over_layer:
		game_over_layer.visible = true
	if game_over_label:
		game_over_label.text = "FACTORY DAMAGED"
	await get_tree().create_timer(2.0).timeout
	_start_round()

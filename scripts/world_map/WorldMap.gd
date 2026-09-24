extends Node2D
## World Map — click-only level selector.
## Landmark transforms are scene-authored. Runtime only toggles locked modulate + is_locked.

const ZONE01_EXTERIOR_PATH := "res://scenes/zone01/Zone01_Exterior.tscn"
const ZONE02_EXTERIOR_PATH := "res://scenes/zone02/Zone02_Exterior.tscn"
const ZONE03_EXTERIOR_PATH := "res://scenes/zone03/Zone03_Exterior.tscn"
const ZONE04_EXTERIOR_PATH := "res://scenes/zone04/Zone04_Exterior.tscn"
const LOCKED_MSG := "Locked — this area is not available yet."
const LOCKED_MODULATE := Color(0.45, 0.45, 0.5, 1.0)
const UNLOCKED_MODULATE := Color(1, 1, 1, 1)

@onready var prompt_label: Label = $UI/PromptLabel
@onready var zone01_root: Node2D = $Landmarks/Zone01
@onready var zone01_click: Area2D = $Landmarks/Zone01/ClickArea
@onready var zone02_root: Node2D = $Landmarks/Zone02_Locked
@onready var zone02_click: Area2D = $Landmarks/Zone02_Locked/ClickArea
@onready var zone03_root: Node2D = $Landmarks/Zone03_Locked
@onready var zone03_click: Area2D = $Landmarks/Zone03_Locked/ClickArea
@onready var zone04_root: Node2D = $Landmarks/Zone04_Locked
@onready var zone04_click: Area2D = $Landmarks/Zone04_Locked/ClickArea
@onready var zone05_root: Node2D = $Landmarks/Zone05_Locked
@onready var zone05_click: Area2D = $Landmarks/Zone05_Locked/ClickArea


func _ready() -> void:
	if prompt_label:
		prompt_label.visible = false
	GameState.sync_world_map_unlocks()
	_apply_landmark_states()
	_wire_click(zone01_click)
	_wire_click(zone02_click)
	_wire_click(zone03_click)
	_wire_click(zone04_click)
	_wire_click(zone05_click)


func _apply_landmark_states() -> void:
	## Visual: unlocked OR completed → full color. Clickable: is_zone_unlocked only.
	## Zone 01 is always available (and full color) for the current development path.
	_set_landmark_state(zone01_root, zone01_click, true, true)
	_set_landmark_state(
		zone02_root,
		zone02_click,
		GameState.is_zone_unlocked(GameState.ZONE_02),
		GameState.is_zone_unlocked(GameState.ZONE_02) or GameState.zone02_minigame_successful
	)
	_set_landmark_state(
		zone03_root,
		zone03_click,
		GameState.is_zone_unlocked(GameState.ZONE_03),
		GameState.is_zone_unlocked(GameState.ZONE_03) or GameState.zone03_minigame_successful
	)
	_set_landmark_state(
		zone04_root,
		zone04_click,
		GameState.is_zone_unlocked(GameState.ZONE_04),
		GameState.is_zone_unlocked(GameState.ZONE_04) or GameState.zone04_minigame_successful
	)
	_set_landmark_state(
		zone05_root,
		zone05_click,
		GameState.is_zone_unlocked(GameState.ZONE_05),
		GameState.is_zone_unlocked(GameState.ZONE_05)
	)


func _set_landmark_state(root: Node2D, click: Area2D, clickable: bool, full_color: bool) -> void:
	if root:
		root.modulate = UNLOCKED_MODULATE if full_color else LOCKED_MODULATE
	if click and "is_locked" in click:
		click.is_locked = not clickable


func _wire_click(area: Area2D) -> void:
	if area == null:
		return
	if area.has_signal("clicked") and not area.clicked.is_connected(_on_landmark_clicked):
		area.clicked.connect(_on_landmark_clicked)


func _on_landmark_clicked(target: Area2D) -> void:
	if target == null:
		return
	var locked := false
	if "is_locked" in target:
		locked = bool(target.is_locked)
	var landmark_id := ""
	if "landmark_id" in target:
		landmark_id = str(target.landmark_id)

	if locked:
		_show_feedback(LOCKED_MSG)
		return

	match landmark_id:
		GameState.ZONE_01, "zone_01":
			_try_enter_path(ZONE01_EXTERIOR_PATH, GameState.ZONE_01)
		GameState.ZONE_02, "zone_02":
			_try_enter_path(ZONE02_EXTERIOR_PATH, GameState.ZONE_02)
		GameState.ZONE_03, "zone_03":
			_try_enter_path(ZONE03_EXTERIOR_PATH, GameState.ZONE_03)
		GameState.ZONE_04, "zone_04":
			_try_enter_path(ZONE04_EXTERIOR_PATH, GameState.ZONE_04)
		GameState.ZONE_05, "zone_05":
			_show_feedback("Zone 05 coming soon.")
		_:
			_show_feedback(LOCKED_MSG)


## Public entry for tests / debug — same as clicking Factory.
func select_zone01() -> void:
	_try_enter_path(ZONE01_EXTERIOR_PATH, GameState.ZONE_01)


func _try_enter_path(path: String, zone_id: String) -> void:
	if not GameState.is_zone_unlocked(zone_id):
		_show_feedback(LOCKED_MSG)
		return
	if not ResourceLoader.exists(path):
		_show_feedback("Coming soon.")
		return
	_hide_feedback()
	_go_scene(path)


func _go_scene(path: String) -> void:
	if SceneTransition.is_busy():
		await SceneTransition.transition_finished
	SceneTransition.change_to(path)


func _show_feedback(text: String) -> void:
	if prompt_label:
		prompt_label.visible = true
		prompt_label.text = text


func _hide_feedback() -> void:
	if prompt_label:
		prompt_label.visible = false

class_name BadgeScreen
extends Control
## Read-only badge collection for the active profile. Does not save or unlock badges.

const WORLD_MAP_PATH := "res://scenes/world_map/WorldMap.tscn"
const HALL_PATH := "res://scenes/Hall of  legends/hall of legends.tscn"

## Set by GameplayStatusBar before SceneTransition into this screen.
static var return_scene_path: String = ""

const BADGE_DEFS: Array[Dictionary] = [
	{
		"name": "Momentum Crest",
		"texture": "res://asset/sprites/Environment/zone 1/badge_momentum_crest (1).png",
		"flag": "zone01_badge_earned",
	},
	{
		"name": "Radiant Crest",
		"texture": "res://asset/sprites/Environment/zone 2/crest radiant.png",
		"flag": "zone02_badge_earned",
	},
	{
		"name": "Spectrum Crest",
		"texture": "res://asset/sprites/Environment/zone 3/spectrum _badge.png",
		"flag": "zone03_badge_earned",
	},
	{
		"name": "Spark Emblem",
		"texture": "res://asset/sprites/Environment/zone 4/ui_badge_spark_emblem.png",
		"flag": "zone04_badge_earned",
	},
	{
		"name": "Atomic Amber",
		"texture": "res://asset/sprites/Environment/Zone_5_badge.png",
		"flag": "zone05_badge_earned",
	},
]

const LOCKED_MODULATE := Color(0.32, 0.32, 0.36, 0.9)
const UNLOCKED_MODULATE := Color(1, 1, 1, 1)

@onready var _player_name_label: Label = $Root/Margin/VBox/Body/LeftColumn/PlayerName
@onready var _count_label: Label = $Root/Margin/VBox/Body/RightColumn/CountLabel
@onready var _badge_list: VBoxContainer = $Root/Margin/VBox/Body/RightColumn/BadgeList
@onready var _hall_button: Button = $Root/Margin/VBox/HallButton
@onready var _back_button: Button = $Root/Margin/VBox/TopBar/BackButton
@onready var _player_portrait: TextureRect = $Root/Margin/VBox/Body/LeftColumn/PlayerPortrait


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_hall_button.pressed.connect(_on_hall_pressed)
	var portrait_path := "res://asset/sprites/character/player front or down.png"
	if ResourceLoader.exists(portrait_path):
		_player_portrait.texture = load(portrait_path)
	_refresh()


func _refresh() -> void:
	var pname := SaveManager.active_profile_name.strip_edges()
	if pname.is_empty():
		pname = "—"
	_player_name_label.text = pname

	var earned := 0
	for child in _badge_list.get_children():
		child.queue_free()

	for def in BADGE_DEFS:
		var is_earned := _is_flag_earned(str(def["flag"]))
		if is_earned:
			earned += 1
		_badge_list.add_child(_make_badge_row(str(def["name"]), str(def["texture"]), is_earned))

	_count_label.text = "%d / 5" % earned
	_hall_button.visible = earned == 5 and _all_five_earned()


func _is_flag_earned(flag_name: String) -> bool:
	## Only use flags that exist on GameState. Zone 05 has none yet → locked.
	match flag_name:
		"zone01_badge_earned":
			return GameState.zone01_badge_earned
		"zone02_badge_earned":
			return GameState.zone02_badge_earned
		"zone03_badge_earned":
			return GameState.zone03_badge_earned
		"zone04_badge_earned":
			return GameState.zone04_badge_earned
		"zone05_badge_earned":
			return false
		_:
			return false


func _all_five_earned() -> bool:
	for def in BADGE_DEFS:
		if not _is_flag_earned(str(def["flag"])):
			return false
	return true


func _make_badge_row(badge_name: String, texture_path: String, earned: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(72, 72)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(texture_path):
		icon.texture = load(texture_path)
	icon.modulate = UNLOCKED_MODULATE if earned else LOCKED_MODULATE
	row.add_child(icon)

	var meta := VBoxContainer.new()
	meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.add_theme_constant_override("separation", 2)

	var title := Label.new()
	title.text = badge_name
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.92, 0.85, 0.65, 1) if earned else Color(0.55, 0.52, 0.48, 1))
	meta.add_child(title)

	var status := Label.new()
	status.text = "Earned" if earned else "Locked"
	status.add_theme_font_size_override("font_size", 14)
	status.add_theme_color_override("font_color", Color(0.7, 0.78, 0.62, 1) if earned else Color(0.5, 0.48, 0.45, 1))
	meta.add_child(status)

	row.add_child(meta)
	return row


func _on_back_pressed() -> void:
	var path := return_scene_path
	if path.is_empty() or not ResourceLoader.exists(path):
		path = WORLD_MAP_PATH
	_go_scene(path)


func _on_hall_pressed() -> void:
	if not _all_five_earned():
		return
	if not ResourceLoader.exists(HALL_PATH):
		push_warning("BadgeScreen: Hall scene missing at %s" % HALL_PATH)
		return
	_go_scene(HALL_PATH)


func _go_scene(path: String) -> void:
	if SceneTransition.is_busy():
		await SceneTransition.transition_finished
	SceneTransition.change_to(path)

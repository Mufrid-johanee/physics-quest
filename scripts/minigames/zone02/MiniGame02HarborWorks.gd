extends Control
## Zone 02 Harbor Works — Create-level machine-building mini-game.
## Assets: res://asset/minigame asset/zone 2 mini game/mini_games_2_asset/
## Self-contained Control (no MiniGameBase).

const WORLD_MAP_PATH := "res://scenes/world_map/WorldMap.tscn"
const BRIEFS_PATH := "res://data/zone02_harbor_briefs.json"
const ASSET_DIR := "res://asset/minigame asset/zone 2 mini game/mini_games_2_asset/"
const G := 9.8
const COLS := 4
const ROWS := 4
const SLOT_COUNT := 16
const TILE_DISPLAY := 88.0

const SOURCE_TYPES := ["motor", "hand_crank", "counterweight"]

const TILE_DEFS := {
	"motor": {"power_w": 400.0, "ma": 1.0, "eta": 1.0},
	"hand_crank": {"power_w": 100.0, "ma": 1.0, "eta": 1.0},
	"counterweight": {"power_w": 0.0, "ma": 1.0, "eta": 1.0},
	"fixed_pulley": {"power_w": 0.0, "ma": 1.0, "eta": 0.95},
	"movable_pulley": {"power_w": 0.0, "ma": 2.0, "eta": 0.90},
	"ramp": {"power_w": 0.0, "ma": 1.0, "eta": 0.90},
	"lever": {"power_w": 0.0, "ma": 1.0, "eta": 0.95},
}

## Disk filenames keep "liver_" for lever art.
const TEX_KEYS := {
	"motor_straight": "motor_straight.png",
	"motor_elbow": "motor_elbow.png",
	"hand_crank_straight": "hand_crank_straight.png",
	"hand_crank_elbow": "hand_crank_elbow.png",
	"counterweight_straight": "counterweight_straight.png",
	"counterweight_elbow": "counterweight_elbow.png",
	"fixed_pulley_straight": "fixed_pulley_straight.png",
	"fixed_pulley_elbow": "fixed_pulley_elbow.png",
	"movable_pulley_straight": "movable_pulley_straight.png",
	"movable_pulley_elbow": "movable_pulley_elbow.png",
	"ramp_straight": "ramp_straight.png",
	"ramp_elbow": "ramp_elbow.png",
	"lever_straight": "liver_straight.png",
	"lever_elbow": "liver_elbow.png",
}

var _tex: Dictionary = {}
var _briefs: Array = []
var _brief_index: int = 0
var _board: Array = []
var _selected_slot: int = -1
var _selected_palette: String = ""
var _sim_locked: bool = false
var _brief_passed: bool = false
var _total_stars: int = 0
var _slots: Array = []
var _slot_sprites: Array = []

@onready var background: TextureRect = $Background
@onready var board_grid: GridContainer = $BoardArea/BoardGrid
@onready var cargo_crate: TextureRect = $BoardArea/LoadZone/CargoCrate
@onready var tile_palette: VBoxContainer = $TilePalette
@onready var brief_title: Label = $BriefPanel/Margin/VBox/BriefTitle
@onready var brief_constraints: Label = $BriefPanel/Margin/VBox/BriefConstraints
@onready var source_allowed: Label = $BriefPanel/Margin/VBox/SourceAllowed
@onready var mass_spin: SpinBox = $ParameterPanel/CounterweightMass
@onready var ramp_slider: HSlider = $ParameterPanel/RampAngle
@onready var ramp_label: Label = $ParameterPanel/RampAngleLabel
@onready var lever_option: OptionButton = $ParameterPanel/LeverRatio
@onready var prediction_input: LineEdit = $PredictionPanel/PredictionInput
@onready var launch_btn: Button = $PredictionPanel/LaunchButton
@onready var readout_bg: TextureRect = $ReadoutPanel/PanelArt
@onready var energy_out_lbl: Label = $ReadoutPanel/Margin/VBox/EnergyOut
@onready var energy_in_lbl: Label = $ReadoutPanel/Margin/VBox/EnergyIn
@onready var time_lbl: Label = $ReadoutPanel/Margin/VBox/TimeTaken
@onready var force_lbl: Label = $ReadoutPanel/Margin/VBox/EffortForce
@onready var eta_lbl: Label = $ReadoutPanel/Margin/VBox/EfficiencyTotal
@onready var pred_result_lbl: Label = $ReadoutPanel/Margin/VBox/PredictionResult
@onready var status_lbl: Label = $ReadoutPanel/Margin/VBox/StatusLabel
@onready var failed_lbl: Label = $ReadoutPanel/Margin/VBox/FailedConstraints
@onready var star1: TextureRect = $StarsPanel/Star1
@onready var star2: TextureRect = $StarsPanel/Star2
@onready var star3: TextureRect = $StarsPanel/Star3
@onready var rotate_btn: Button = $RotateButton
@onready var remove_btn: Button = $RemoveButton
@onready var next_brief_btn: Button = $NextBriefButton
@onready var complete_banner: Label = $CompleteBanner
@onready var validity_lbl: Label = $ValidityLabel


func _ready() -> void:
	_load_textures()
	_apply_static_textures()
	_init_board_array()
	_build_slots()
	_build_palette()
	_wire_ui()
	_load_briefs()
	if complete_banner:
		complete_banner.visible = false
	if next_brief_btn:
		next_brief_btn.visible = false
	_setup_brief(0)
	_clear_readout()
	_update_board_visuals()
	_update_parameter_panel()
	_refresh_validity()


func _load_textures() -> void:
	var always := {
		"bg": "harbor_works_bg.png",
		"crate": "cargo_crate.png",
		"readout": "read_out_panel.png",
		"star_empty": "star_empty.png",
		"star_filled": "star_filled.png",
	}
	for k in always:
		var p: String = ASSET_DIR + str(always[k])
		_tex[k] = load(p) if ResourceLoader.exists(p) else null
	for k in TEX_KEYS:
		var p2: String = ASSET_DIR + str(TEX_KEYS[k])
		_tex[k] = load(p2) if ResourceLoader.exists(p2) else null


func _apply_static_textures() -> void:
	if background and _tex.get("bg"):
		background.texture = _tex["bg"]
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if cargo_crate and _tex.get("crate"):
		cargo_crate.texture = _tex["crate"]
		cargo_crate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cargo_crate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cargo_crate.custom_minimum_size = Vector2(96, 96)
	if readout_bg and _tex.get("readout"):
		readout_bg.texture = _tex["readout"]
		readout_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		readout_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_set_star_tex(star1, false)
	_set_star_tex(star2, false)
	_set_star_tex(star3, false)


func _set_star_tex(tr: TextureRect, filled: bool) -> void:
	if tr == null:
		return
	var key := "star_filled" if filled else "star_empty"
	tr.texture = _tex.get(key)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(48, 48)


func _init_board_array() -> void:
	_board.clear()
	for i in SLOT_COUNT:
		_board.append(null)


func _build_slots() -> void:
	_slots.clear()
	_slot_sprites.clear()
	if board_grid == null:
		return
	for c in board_grid.get_children():
		c.queue_free()
	board_grid.columns = COLS
	for i in SLOT_COUNT:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(TILE_DISPLAY + 8, TILE_DISPLAY + 8)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.16, 0.22, 0.85)
		sb.border_color = Color(0.45, 0.55, 0.65)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(4)
		panel.add_theme_stylebox_override("panel", sb)
		var spr := TextureRect.new()
		spr.name = "TileSprite"
		spr.set_anchors_preset(Control.PRESET_FULL_RECT)
		spr.offset_left = 4
		spr.offset_top = 4
		spr.offset_right = -4
		spr.offset_bottom = -4
		spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(spr)
		var idx := i
		panel.gui_input.connect(func(ev: InputEvent): _on_slot_gui(idx, ev))
		board_grid.add_child(panel)
		_slots.append(panel)
		_slot_sprites.append(spr)


func _build_palette() -> void:
	if tile_palette == null:
		return
	for c in tile_palette.get_children():
		c.queue_free()
	var title := Label.new()
	title.text = "MACHINE TILES"
	tile_palette.add_child(title)
	var types := [
		["motor", "Motor"],
		["hand_crank", "Hand Crank"],
		["counterweight", "Counterweight"],
		["fixed_pulley", "Fixed Pulley"],
		["movable_pulley", "Movable Pulley"],
		["ramp", "Ramp"],
		["lever", "Lever"],
	]
	for t in types:
		for variant in ["straight", "elbow"]:
			var key: String = "%s|%s" % [t[0], variant]
			var btn := Button.new()
			btn.text = "%s (%s)" % [t[1], variant]
			btn.custom_minimum_size = Vector2(170, 28)
			btn.pressed.connect(_on_palette_tile_selected.bind(key))
			var icon_key: String = "%s_%s" % [t[0], variant]
			if _tex.get(icon_key):
				btn.icon = _tex[icon_key]
				btn.expand_icon = true
			tile_palette.add_child(btn)


func _wire_ui() -> void:
	if launch_btn and not launch_btn.pressed.is_connected(_on_launch_pressed):
		launch_btn.pressed.connect(_on_launch_pressed)
	if rotate_btn and not rotate_btn.pressed.is_connected(_on_rotate_pressed):
		rotate_btn.pressed.connect(_on_rotate_pressed)
	if remove_btn and not remove_btn.pressed.is_connected(_on_remove_pressed):
		remove_btn.pressed.connect(_on_remove_pressed)
	if next_brief_btn and not next_brief_btn.pressed.is_connected(_on_next_brief_pressed):
		next_brief_btn.pressed.connect(_on_next_brief_pressed)
	if mass_spin:
		mass_spin.min_value = 50
		mass_spin.max_value = 200
		mass_spin.step = 1
		mass_spin.value = 100
		if not mass_spin.value_changed.is_connected(_on_mass_changed):
			mass_spin.value_changed.connect(_on_mass_changed)
	if ramp_slider:
		ramp_slider.min_value = 10
		ramp_slider.max_value = 40
		ramp_slider.step = 1
		ramp_slider.value = 25
		if not ramp_slider.value_changed.is_connected(_on_angle_changed):
			ramp_slider.value_changed.connect(_on_angle_changed)
	if lever_option:
		lever_option.clear()
		lever_option.add_item("1:1", 1)
		lever_option.add_item("1:2", 2)
		lever_option.add_item("1:3", 3)
		lever_option.add_item("1:4", 4)
		if not lever_option.item_selected.is_connected(_on_ratio_selected):
			lever_option.item_selected.connect(_on_ratio_selected)


func _load_briefs() -> void:
	_briefs.clear()
	if not FileAccess.file_exists(BRIEFS_PATH):
		push_error("HarborWorks: missing briefs JSON")
		return
	var f := FileAccess.open(BRIEFS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_ARRAY:
		_briefs = parsed
	elif typeof(parsed) == TYPE_DICTIONARY and parsed.has("briefs"):
		_briefs = parsed["briefs"]


func _brief() -> Dictionary:
	if _brief_index < 0 or _brief_index >= _briefs.size():
		return {}
	return _briefs[_brief_index]


func _setup_brief(index: int) -> void:
	_brief_index = clampi(index, 0, maxi(_briefs.size() - 1, 0))
	_brief_passed = false
	_sim_locked = false
	_selected_slot = -1
	_selected_palette = ""
	if next_brief_btn:
		next_brief_btn.visible = false
	var b: Dictionary = _brief()
	if brief_title:
		brief_title.text = "HARBOR WORKS — %s" % str(b.get("title", "Brief"))
	var lines: PackedStringArray = []
	lines.append("Cargo: %s kg" % str(b.get("mass_kg", "?")))
	lines.append("Lift height: %s m" % str(b.get("height_m", "?")))
	if b.get("max_energy_j") != null:
		lines.append("Max input energy: %s J" % str(b["max_energy_j"]))
	if b.get("max_time_s") != null:
		lines.append("Max time: %s s" % str(b["max_time_s"]))
	if b.get("max_force_n") != null:
		lines.append("Max effort force: %s N" % str(b["max_force_n"]))
	if b.get("max_arrival_speed_ms") != null:
		lines.append("Max arrival speed: %s m/s" % str(b["max_arrival_speed_ms"]))
	if brief_constraints:
		brief_constraints.text = "\n".join(lines)
	var allowed: Array = b.get("allowed_sources", [])
	if source_allowed:
		source_allowed.text = "Allowed sources: %s" % ", ".join(PackedStringArray(allowed))
	_set_star_tex(star1, false)
	_set_star_tex(star2, false)
	_set_star_tex(star3, false)
	_clear_readout()
	_refresh_validity()


func _on_palette_tile_selected(key: String) -> void:
	if _sim_locked:
		return
	_selected_palette = key
	_selected_slot = -1
	_update_parameter_panel()
	_highlight_selection()


func _on_slot_gui(slot_index: int, event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_on_slot_clicked(slot_index)


func _on_slot_clicked(slot_index: int) -> void:
	if _sim_locked:
		return
	if _board[slot_index] == null:
		if _selected_slot >= 0 and _board[_selected_slot] != null:
			if _is_adjacent(_selected_slot, slot_index):
				_try_slide_tile(_selected_slot, slot_index)
				return
		if _selected_palette != "":
			_try_place_tile(slot_index)
			return
		_selected_slot = -1
	else:
		_selected_slot = slot_index
		_selected_palette = ""
		_update_parameter_panel()
	_highlight_selection()
	_refresh_validity()


func _try_place_tile(slot_index: int) -> void:
	if _board[slot_index] != null or _selected_palette == "":
		return
	var parts := _selected_palette.split("|")
	if parts.size() != 2:
		return
	var ttype: String = parts[0]
	var variant: String = parts[1]
	var orient := 0
	var tile := {
		"type": ttype,
		"variant": variant,
		"orientation_deg": orient,
		"ports": _ports_for(variant, orient),
		"mass": 100.0,
		"angle": 25.0,
		"ratio": 1,
	}
	_board[slot_index] = tile
	_selected_slot = slot_index
	_selected_palette = ""
	_update_board_visuals()
	_update_parameter_panel()
	_refresh_validity()


func _try_slide_tile(from_slot: int, to_slot: int) -> void:
	if _board[from_slot] == null or _board[to_slot] != null:
		return
	if not _is_adjacent(from_slot, to_slot):
		return
	_board[to_slot] = _board[from_slot]
	_board[from_slot] = null
	_selected_slot = to_slot
	_update_board_visuals()
	_update_parameter_panel()
	_refresh_validity()


func _is_adjacent(a: int, b: int) -> bool:
	var ax := a % COLS
	var ay := a / COLS
	var bx := b % COLS
	var by := b / COLS
	return absi(ax - bx) + absi(ay - by) == 1


func _ports_for(variant: String, orient_deg: int) -> Array:
	if variant == "straight":
		return ["LEFT", "RIGHT"]
	match orient_deg:
		0:
			return ["RIGHT", "DOWN"]
		90:
			return ["DOWN", "LEFT"]
		180:
			return ["LEFT", "UP"]
		270:
			return ["UP", "RIGHT"]
		_:
			return ["RIGHT", "DOWN"]


func _on_rotate_pressed() -> void:
	if _sim_locked or _selected_slot < 0:
		return
	var tile = _board[_selected_slot]
	if tile == null or str(tile["variant"]) != "elbow":
		return
	var o: int = int(tile["orientation_deg"])
	o = (o + 90) % 360
	tile["orientation_deg"] = o
	tile["ports"] = _ports_for("elbow", o)
	_board[_selected_slot] = tile
	_update_board_visuals()
	_refresh_validity()


func _on_remove_pressed() -> void:
	if _sim_locked or _selected_slot < 0:
		return
	_board[_selected_slot] = null
	_selected_slot = -1
	_update_board_visuals()
	_update_parameter_panel()
	_refresh_validity()


func _on_mass_changed(v: float) -> void:
	if _selected_slot < 0 or _board[_selected_slot] == null:
		return
	var tile: Dictionary = _board[_selected_slot]
	if str(tile["type"]) != "counterweight":
		return
	tile["mass"] = v
	_board[_selected_slot] = tile


func _on_angle_changed(v: float) -> void:
	if ramp_label:
		ramp_label.text = "Ramp angle: %.0f°" % v
	if _selected_slot < 0 or _board[_selected_slot] == null:
		return
	var tile: Dictionary = _board[_selected_slot]
	if str(tile["type"]) != "ramp":
		return
	tile["angle"] = v
	_board[_selected_slot] = tile


func _on_ratio_selected(idx: int) -> void:
	if _selected_slot < 0 or _board[_selected_slot] == null:
		return
	var tile: Dictionary = _board[_selected_slot]
	if str(tile["type"]) != "lever":
		return
	tile["ratio"] = lever_option.get_item_id(idx)
	_board[_selected_slot] = tile


func _tile_ma(tile: Dictionary) -> float:
	var t: String = str(tile["type"])
	if t == "ramp":
		var ang: float = deg_to_rad(float(tile.get("angle", 25.0)))
		return 1.0 / maxf(sin(ang), 0.001)
	if t == "lever":
		return float(tile.get("ratio", 1))
	return float(TILE_DEFS[t]["ma"])


func _tile_eta(tile: Dictionary) -> float:
	return float(TILE_DEFS[str(tile["type"])]["eta"])


func _opposite(dir: String) -> String:
	match dir:
		"LEFT":
			return "RIGHT"
		"RIGHT":
			return "LEFT"
		"UP":
			return "DOWN"
		"DOWN":
			return "UP"
	return ""


func _neighbor(slot: int, dir: String) -> int:
	var x := slot % COLS
	var y := slot / COLS
	match dir:
		"LEFT":
			x -= 1
		"RIGHT":
			x += 1
		"UP":
			y -= 1
		"DOWN":
			y += 1
	if x < 0 or x >= COLS or y < 0 or y >= ROWS:
		return -1
	return y * COLS + x


func _validate_machine() -> bool:
	return not _find_machine_path().is_empty()


func _find_machine_path() -> Array:
	var starts: Array = []
	for i in SLOT_COUNT:
		if _board[i] == null:
			continue
		if i % COLS != 0:
			continue
		if (_board[i]["ports"] as Array).has("LEFT"):
			starts.append(i)
	for start in starts:
		var path := _bfs_path(int(start))
		if not path.is_empty() and _path_has_valid_source(path):
			return path
	return []


func _path_has_valid_source(path: Array) -> bool:
	var allowed: Array = _brief().get("allowed_sources", [])
	for idx in path:
		var tile = _board[idx]
		if tile == null:
			continue
		var t: String = str(tile["type"])
		if t in SOURCE_TYPES and allowed.has(t):
			return true
	return false


func _bfs_path(start: int) -> Array:
	var queue: Array = [[start]]
	var visited: Dictionary = {}
	visited[start] = true
	while not queue.is_empty():
		var path: Array = queue.pop_front()
		var cur: int = int(path[path.size() - 1])
		var tile = _board[cur]
		if tile == null:
			continue
		if cur % COLS == COLS - 1 and (tile["ports"] as Array).has("RIGHT"):
			return path
		for dir in tile["ports"]:
			var n: int = _neighbor(cur, str(dir))
			if n < 0 or _board[n] == null or visited.has(n):
				continue
			var nports: Array = _board[n]["ports"]
			if not nports.has(_opposite(str(dir))):
				continue
			visited[n] = true
			var np: Array = path.duplicate()
			np.append(n)
			queue.append(np)
	return []


func _get_source_tile(path: Array) -> Dictionary:
	var allowed: Array = _brief().get("allowed_sources", [])
	for idx in path:
		var tile = _board[idx]
		if tile == null:
			continue
		var t: String = str(tile["type"])
		if t in SOURCE_TYPES and allowed.has(t):
			return tile
	return {}


func _calculate_physics() -> Dictionary:
	var path := _find_machine_path()
	var b: Dictionary = _brief()
	var mass: float = float(b.get("mass_kg", 0))
	var height: float = float(b.get("height_m", 0))
	var w_out: float = mass * G * height
	var eta_total := 1.0
	var ma_total := 1.0
	for idx in path:
		var tile: Dictionary = _board[idx]
		eta_total *= _tile_eta(tile)
		ma_total *= _tile_ma(tile)
	var source: Dictionary = _get_source_tile(path)
	var stype: String = str(source.get("type", ""))
	var energy_in := 0.0
	var time_s := 0.0
	var force_n := 0.0
	var arrival_speed := 0.0
	if stype == "counterweight":
		var cm: float = float(source.get("mass", 100.0))
		energy_in = cm * G * 5.0
		time_s = sqrt(2.0 * height / G)
		force_n = cm * G
		## Surplus after lift becomes arrival KE (playable Brief 3).
		## Raw W_out*η as KE is always >> 1 m/s and makes Storm Blackout impossible.
		var available: float = energy_in * eta_total
		var ke: float = maxf(0.0, available - w_out)
		arrival_speed = sqrt(2.0 * ke / maxf(mass, 0.001))
		if available + 0.001 < w_out:
			arrival_speed = 999.0 # mark as failed lift
	else:
		energy_in = w_out / maxf(eta_total, 0.0001)
		var power_w: float = float(TILE_DEFS.get(stype, {}).get("power_w", 100.0))
		time_s = energy_in / maxf(power_w, 0.001)
		force_n = energy_in / maxf(height, 0.001)
	return {
		"path": path,
		"w_out": w_out,
		"energy_in": energy_in,
		"time": time_s,
		"force": force_n,
		"eta_total": eta_total,
		"ma_total": ma_total,
		"arrival_speed": arrival_speed,
		"source_type": stype,
		"valid": not path.is_empty() and stype != "",
	}


func _check_constraints(results: Dictionary) -> Dictionary:
	var b: Dictionary = _brief()
	var failed: PackedStringArray = []
	var ok := true
	if not bool(results.get("valid", false)):
		failed.append("Invalid machine path or source")
		ok = false
	var allowed: Array = b.get("allowed_sources", [])
	var st: String = str(results.get("source_type", ""))
	if st != "" and not allowed.has(st):
		failed.append("Source '%s' not allowed for this brief" % st)
		ok = false
	if b.get("max_energy_j") != null:
		var lim: float = float(b["max_energy_j"])
		if float(results["energy_in"]) > lim + 0.001:
			failed.append("Energy: %.1f J > %s J" % [float(results["energy_in"]), str(lim)])
			ok = false
	if b.get("max_time_s") != null:
		var tlim: float = float(b["max_time_s"])
		if float(results["time"]) > tlim + 0.001:
			failed.append("Time: %.2f s > %s s" % [float(results["time"]), str(tlim)])
			ok = false
	if b.get("max_force_n") != null:
		var flim: float = float(b["max_force_n"])
		if float(results["force"]) > flim + 0.001:
			failed.append("Force: %.1f N > %s N" % [float(results["force"]), str(flim)])
			ok = false
	if b.get("max_arrival_speed_ms") != null:
		var slim: float = float(b["max_arrival_speed_ms"])
		if float(results["arrival_speed"]) > slim + 0.001:
			failed.append("Arrival speed: %.3f m/s > %s m/s" % [float(results["arrival_speed"]), str(slim)])
			ok = false
	return {"passed": ok, "failed": failed}


func _award_stars(constraints_passed: bool, error_pct: float, eta_total: float) -> int:
	var n := 0
	if constraints_passed:
		n = 1
		if error_pct <= 5.0:
			n = 2
			if eta_total >= 0.85:
				n = 3
	_set_star_tex(star1, n >= 1)
	_set_star_tex(star2, n >= 2)
	_set_star_tex(star3, n >= 3)
	return n


func _on_launch_pressed() -> void:
	if _brief_passed:
		return
	if not _validate_machine():
		if status_lbl:
			status_lbl.text = "STATUS: Invalid Machine"
			status_lbl.modulate = Color(1.0, 0.45, 0.35)
		if failed_lbl:
			failed_lbl.text = "Build a continuous Source→Load path with an allowed source."
		return
	var pred_txt := prediction_input.text.strip_edges() if prediction_input else ""
	if pred_txt == "" or not pred_txt.is_valid_float():
		if status_lbl:
			status_lbl.text = "STATUS: Enter a valid predicted energy (J)"
		return
	var prediction := float(pred_txt)
	if prediction < 0.0:
		if status_lbl:
			status_lbl.text = "STATUS: Prediction cannot be negative"
		return

	_sim_locked = true
	_set_editing_enabled(false)
	var results := _calculate_physics()
	var check := _check_constraints(results)
	var w_in: float = float(results["energy_in"])
	var error_pct: float = absf(prediction - w_in) / maxf(w_in, 0.001) * 100.0
	var stars: int = _award_stars(bool(check["passed"]), error_pct, float(results["eta_total"]))
	await _animate_launch(results)
	_update_readout(results, stars, prediction, error_pct, check)
	if bool(check["passed"]):
		_brief_passed = true
		_total_stars += stars
		if next_brief_btn:
			next_brief_btn.visible = true
			if _brief_index >= _briefs.size() - 1:
				next_brief_btn.text = "COMPLETE HARBOR WORKS"
			else:
				next_brief_btn.text = "NEXT BRIEF"
	else:
		_sim_locked = false
		_set_editing_enabled(true)


func _animate_launch(results: Dictionary) -> void:
	var path: Array = results.get("path", [])
	for idx in path:
		if idx < _slots.size() and _slots[idx]:
			_slots[idx].modulate = Color(1.3, 1.5, 0.8)
		await get_tree().create_timer(0.12).timeout
	if cargo_crate:
		var start_y := cargo_crate.position.y
		var tw := create_tween()
		tw.tween_property(cargo_crate, "position:y", start_y - 40.0, 0.45)
		await tw.finished
		var tw2 := create_tween()
		tw2.tween_property(cargo_crate, "position:y", start_y, 0.25)
		await tw2.finished
	for idx in path:
		if idx < _slots.size() and _slots[idx]:
			_slots[idx].modulate = Color.WHITE


func _update_readout(results: Dictionary, stars: int, prediction: float, error_pct: float, check: Dictionary) -> void:
	if energy_out_lbl:
		energy_out_lbl.text = "OUTPUT WORK  %.1f J" % float(results["w_out"])
	if energy_in_lbl:
		energy_in_lbl.text = "INPUT ENERGY  %.1f J" % float(results["energy_in"])
	if time_lbl:
		time_lbl.text = "TIME  %.2f s" % float(results["time"])
	if force_lbl:
		force_lbl.text = "EFFORT FORCE  %.1f N" % float(results["force"])
	if eta_lbl:
		eta_lbl.text = "EFFICIENCY  %.0f%%   MA  %.2f" % [float(results["eta_total"]) * 100.0, float(results["ma_total"])]
	if pred_result_lbl:
		pred_result_lbl.text = "PREDICTED  %.1f J   ERROR  %.2f%%" % [prediction, error_pct]
	if bool(check["passed"]):
		if status_lbl:
			status_lbl.text = "STATUS: PASSED  (%d★)" % stars
			status_lbl.modulate = Color(0.45, 1.0, 0.55)
		if failed_lbl:
			failed_lbl.text = ""
	else:
		if status_lbl:
			status_lbl.text = "STATUS: FAILED"
			status_lbl.modulate = Color(1.0, 0.45, 0.35)
		var fails: PackedStringArray = check.get("failed", [])
		if failed_lbl:
			failed_lbl.text = "%d CONSTRAINT(S) FAILED\n%s" % [fails.size(), "\n".join(fails)]


func _clear_readout() -> void:
	for lbl in [energy_out_lbl, energy_in_lbl, time_lbl, force_lbl, eta_lbl, pred_result_lbl, failed_lbl]:
		if lbl:
			lbl.text = ""
	if status_lbl:
		status_lbl.text = "STATUS: —"
		status_lbl.modulate = Color.WHITE


func _on_next_brief_pressed() -> void:
	if not _brief_passed:
		return
	if _brief_index >= _briefs.size() - 1:
		_floor_complete()
		return
	_init_board_array()
	_selected_slot = -1
	_sim_locked = false
	_set_editing_enabled(true)
	_setup_brief(_brief_index + 1)
	_update_board_visuals()
	_update_parameter_panel()


func _floor_complete() -> void:
	if complete_banner:
		complete_banner.visible = true
		complete_banner.text = "HARBOR WORKS COMPLETE\nTotal stars: %d\nZone 03 unlocked on the World Map." % _total_stars
	if next_brief_btn:
		next_brief_btn.visible = false
	_sim_locked = true
	_set_editing_enabled(false)
	GameState.zone02_badge_earned = true
	GameState.mark_minigame_successful(GameState.ZONE_02)
	await get_tree().create_timer(1.6).timeout
	if SceneTransition.is_busy():
		await SceneTransition.transition_finished
	SceneTransition.change_to(WORLD_MAP_PATH)


func _set_editing_enabled(enabled: bool) -> void:
	if launch_btn:
		launch_btn.disabled = not enabled
	if rotate_btn:
		rotate_btn.disabled = not enabled
	if remove_btn:
		remove_btn.disabled = not enabled
	if prediction_input:
		prediction_input.editable = enabled


func _update_board_visuals() -> void:
	for i in SLOT_COUNT:
		if i >= _slot_sprites.size():
			continue
		var spr: TextureRect = _slot_sprites[i]
		var tile = _board[i]
		if tile == null:
			spr.texture = null
			spr.rotation_degrees = 0.0
			continue
		var key: String = "%s_%s" % [str(tile["type"]), str(tile["variant"])]
		spr.texture = _tex.get(key)
		if str(tile["variant"]) == "elbow":
			spr.pivot_offset = spr.size * 0.5
			spr.rotation_degrees = float(tile.get("orientation_deg", 0))
		else:
			spr.rotation_degrees = 0.0
	_highlight_selection()


func _highlight_selection() -> void:
	for i in _slots.size():
		var p: Panel = _slots[i]
		var sb := StyleBoxFlat.new()
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(4)
		if i == _selected_slot:
			sb.bg_color = Color(0.22, 0.28, 0.18, 0.9)
			sb.border_color = Color(0.95, 0.85, 0.35)
		else:
			sb.bg_color = Color(0.12, 0.16, 0.22, 0.85)
			sb.border_color = Color(0.45, 0.55, 0.65)
		p.add_theme_stylebox_override("panel", sb)


func _update_parameter_panel() -> void:
	var show_mass := false
	var show_angle := false
	var show_ratio := false
	var show_rot := false
	if _selected_slot >= 0 and _board[_selected_slot] != null:
		var tile: Dictionary = _board[_selected_slot]
		var t: String = str(tile["type"])
		show_mass = t == "counterweight"
		show_angle = t == "ramp"
		show_ratio = t == "lever"
		show_rot = str(tile["variant"]) == "elbow"
		if show_mass and mass_spin:
			mass_spin.value = float(tile.get("mass", 100))
		if show_angle and ramp_slider:
			ramp_slider.value = float(tile.get("angle", 25))
			if ramp_label:
				ramp_label.text = "Ramp angle: %.0f°" % ramp_slider.value
		if show_ratio and lever_option:
			var r: int = int(tile.get("ratio", 1))
			for i in lever_option.item_count:
				if lever_option.get_item_id(i) == r:
					lever_option.select(i)
					break
	if mass_spin:
		mass_spin.visible = show_mass
	if ramp_slider:
		ramp_slider.visible = show_angle
	if ramp_label:
		ramp_label.visible = show_angle
	if lever_option:
		lever_option.visible = show_ratio
	if rotate_btn:
		rotate_btn.visible = show_rot
	if remove_btn:
		remove_btn.visible = _selected_slot >= 0 and _board[_selected_slot] != null


func _refresh_validity() -> void:
	var ok := _validate_machine()
	if validity_lbl:
		if ok:
			validity_lbl.text = "Machine path: CONNECTED"
			validity_lbl.modulate = Color(0.5, 1.0, 0.6)
		else:
			validity_lbl.text = "Machine path: INCOMPLETE"
			validity_lbl.modulate = Color(1.0, 0.7, 0.4)

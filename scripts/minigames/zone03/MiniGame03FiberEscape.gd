extends Control
## Zone 03 Fiber Escape — beam-routing puzzle (Server Room → Transoceanic Cable).
## Assets: res://asset/minigame asset/zone 3 mini game/mini game 3 asset/ (JPG)
## Mechanics adapted from fiber_escape_implementation_plan.md (HTML → Godot).

const WORLD_MAP_PATH := "res://scenes/world_map/WorldMap.tscn"
const ASSET_DIR := "res://asset/minigame asset/zone 3 mini game/mini game 3 asset/"
const CHROMA_SHADER := "res://shaders/chroma_key_jpg.gdshader"
const FIELD_SIZE := Vector2(800, 480)

## Stage layouts are tunable fallbacks. Apply only on stage enter / Clear — never every frame.
## 5 obstacle instances total across both stages (plan §5).
const STAGES: Array = [
	{
		"id": "server_room",
		"name": "SERVER ROOM",
		"critical_angle": 55.0,
		"tint_deg": 0.0,
		"emitter": Vector2(70, 240),
		"sensor": Vector2(730, 240),
		"waypoints": [Vector2(300, 280), Vector2(520, 380)],
		"obstacles": [
			Rect2(340, 180, 100, 140),
			Rect2(300, 340, 200, 80),
		],
		"ghost": [Vector2(280, 80), Vector2(560, 80)],
		"hint1": "Keep each bend gentle. Incidence at a bend must stay ≥ 55° (critical angle) or the beam leaks.",
	},
	{
		"id": "transoceanic",
		"name": "TRANSOCEANIC CABLE",
		"critical_angle": 68.0,
		"tint_deg": 165.0,
		"emitter": Vector2(60, 60),
		"sensor": Vector2(740, 80),
		"waypoints": [Vector2(220, 300), Vector2(420, 300), Vector2(600, 300)],
		"obstacles": [
			Rect2(180, 120, 80, 200),
			Rect2(360, 160, 100, 200),
			Rect2(540, 120, 80, 220),
		],
		"ghost": [Vector2(250, 50), Vector2(450, 50), Vector2(650, 50)],
		"hint1": "Critical angle is 68° — bends must be even gentler. Incidence ≥ 68° at every waypoint.",
	},
]

@onready var background: ColorRect = $Background
@onready var playfield: Control = $Playfield
@onready var beam_layer: Node2D = $Playfield/BeamLayer
@onready var hazard_layer: Node2D = $Playfield/HazardLayer
@onready var obstacle_layer: Node2D = $Playfield/ObstacleLayer
@onready var ghost_layer: Node2D = $Playfield/GhostLayer
@onready var waypoint_layer: Node2D = $Playfield/WaypointLayer
@onready var emitter: Sprite2D = $Playfield/Emitter
@onready var sensor: Sprite2D = $Playfield/Sensor
@onready var beam_head: Sprite2D = $Playfield/BeamHead
@onready var particle_layer: Node2D = $Playfield/ParticleLayer
@onready var title_label: Label = $HUD/TitleLabel
@onready var status_icon: TextureRect = $HUD/StatusIcon
@onready var status_label: Label = $HUD/StatusLabel
@onready var critical_label: Label = $HUD/CriticalLabel
@onready var tab1_btn: TextureButton = $HUD/StageTabs/Tab1
@onready var tab2_btn: TextureButton = $HUD/StageTabs/Tab2
@onready var fire_btn: TextureButton = $HUD/Buttons/FireButton
@onready var undo_btn: TextureButton = $HUD/Buttons/UndoButton
@onready var clear_btn: TextureButton = $HUD/Buttons/ClearButton
@onready var hint1_btn: TextureButton = $HUD/Buttons/Hint1Button
@onready var hint2_btn: TextureButton = $HUD/Buttons/Hint2Button
@onready var hint3_btn: TextureButton = $HUD/Buttons/Hint3Button
@onready var result_layer: CanvasLayer = $ResultLayer
@onready var result_label: Label = $ResultLayer/Center/VBox/ResultLabel
@onready var result_btn: Button = $ResultLayer/Center/VBox/ResultButton

var _tex: Dictionary = {}
var _chroma_mat: ShaderMaterial
var _stage_index: int = 0
var _stage1_cleared: bool = false
var _waypoints: Array[Vector2] = []
var _undo_stack: Array = []
var _hint_level: int = 0
var _locked: bool = false
var _firing: bool = false
var _dragging: int = -1
var _drag_offset: Vector2 = Vector2.ZERO
var _bend_ok: Array[bool] = []
var _particles: Array = []
var _glow_frame: int = 0
var _glow_timer: float = 0.0
var _beam_progress: float = 0.0
var _fire_fail_at: float = -1.0
var _fire_done: bool = false
var _path_cache: PackedVector2Array = PackedVector2Array()
var _path_lengths: PackedFloat32Array = PackedFloat32Array()
var _total_len: float = 0.0


func _ready() -> void:
	_load_textures()
	_setup_chroma()
	_wire_ui()
	if result_layer:
		result_layer.visible = false
	beam_head.visible = false
	_enter_stage(0, true)


func _load_textures() -> void:
	var keys := {
		"emitter": "emitter.jpg",
		"sensor": "Sensor_ring.jpg",
		"waypoint": "waypoint.jpg",
		"beam_glow_01": "beam_glow_01.jpg",
		"beam_glow_02": "beam_glow_02.jpg",
		"beam_segment": "beam_segment_tile.jpg",
		"particle": "particle.jpg",
		"obstacle": "obstacle_block.jpg",
		"hazard": "hazard_stripe_tile.jpg",
		"icon_tab": "icon_tab.jpg",
		"icon_fire": "icon_fire.jpg",
		"icon_undo": "icon_undo.jpg",
		"icon_clear": "Icon_clear.jpg",
		"icon_hint": "icon_hint.jpg",
		"icon_status": "icon_status.jpg",
	}
	for k in keys:
		var path: String = ASSET_DIR + str(keys[k])
		if ResourceLoader.exists(path):
			_tex[k] = load(path)
		else:
			push_warning("FiberEscape: missing asset %s" % path)
			_tex[k] = null


func _setup_chroma() -> void:
	if not ResourceLoader.exists(CHROMA_SHADER):
		return
	var sh: Shader = load(CHROMA_SHADER)
	if sh == null:
		return
	_chroma_mat = ShaderMaterial.new()
	_chroma_mat.shader = sh
	_chroma_mat.set_shader_parameter("threshold", 0.12)
	_chroma_mat.set_shader_parameter("softness", 0.08)


func _apply_sprite(spr: Sprite2D, key: String, display_size: float) -> void:
	if spr == null:
		return
	var t: Texture2D = _tex.get(key) as Texture2D
	if t == null:
		spr.texture = null
		return
	spr.texture = t
	if _chroma_mat:
		spr.material = _chroma_mat
	var sz: Vector2 = t.get_size()
	var s: float = display_size / maxf(sz.x, sz.y)
	spr.scale = Vector2(s, s)
	spr.centered = true


func _wire_ui() -> void:
	_setup_icon_btn(fire_btn, "icon_fire", _on_fire)
	_setup_icon_btn(undo_btn, "icon_undo", _on_undo)
	_setup_icon_btn(clear_btn, "icon_clear", _on_clear)
	_setup_icon_btn(hint1_btn, "icon_hint", _on_hint.bind(1))
	_setup_icon_btn(hint2_btn, "icon_hint", _on_hint.bind(2))
	_setup_icon_btn(hint3_btn, "icon_hint", _on_hint.bind(3))
	_setup_icon_btn(tab1_btn, "icon_tab", _on_tab.bind(0))
	_setup_icon_btn(tab2_btn, "icon_tab", _on_tab.bind(1))
	if status_icon and _tex.get("icon_status"):
		status_icon.texture = _tex["icon_status"]
		if _chroma_mat:
			status_icon.material = _chroma_mat
	if result_btn and not result_btn.pressed.is_connected(_on_result_btn):
		result_btn.pressed.connect(_on_result_btn)


func _setup_icon_btn(btn: TextureButton, key: String, cb: Callable) -> void:
	if btn == null:
		return
	var t: Texture2D = _tex.get(key) as Texture2D
	if t:
		btn.texture_normal = t
		if _chroma_mat:
			btn.material = _chroma_mat
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	if not btn.pressed.is_connected(cb):
		btn.pressed.connect(cb)
	btn.mouse_entered.connect(func(): if not _locked: btn.modulate = Color(1.25, 1.25, 1.25))
	btn.mouse_exited.connect(func(): btn.modulate = Color.WHITE)


func _stage() -> Dictionary:
	return STAGES[_stage_index]


func _enter_stage(idx: int, force_reset: bool) -> void:
	_stage_index = clampi(idx, 0, STAGES.size() - 1)
	_locked = false
	_firing = false
	_fire_done = false
	_fire_fail_at = -1.0
	_dragging = -1
	_hint_level = 0
	_particles.clear()
	beam_head.visible = false
	if result_layer:
		result_layer.visible = false
	if force_reset or _waypoints.is_empty():
		_waypoints.clear()
		for p in _stage()["waypoints"]:
			_waypoints.append(p as Vector2)
		_undo_stack.clear()
	_apply_stage_visuals()
	_rebuild_markers()
	_refresh_status()
	_redraw_static()


func _apply_stage_visuals() -> void:
	var st: Dictionary = _stage()
	var tint: float = float(st["tint_deg"])
	if background:
		# Stage wash (plan §6 — code-only, no bg asset).
		var base := Color(0.06, 0.09, 0.14) if _stage_index == 0 else Color(0.04, 0.10, 0.14)
		background.color = base
	title_label.text = "FIBER ESCAPE — %s" % str(st["name"])
	critical_label.text = "Critical angle θc = %.0f°" % float(st["critical_angle"])
	_apply_sprite(emitter, "emitter", 48.0)
	_apply_sprite(sensor, "sensor", 56.0)
	_apply_sprite(beam_head, "beam_glow_01", 28.0)
	emitter.position = st["emitter"]
	sensor.position = st["sensor"]
	emitter.modulate = _hue_mod(tint, 1.0)
	sensor.modulate = Color.WHITE
	sensor.scale = sensor.scale # keep size
	tab1_btn.disabled = false
	tab2_btn.disabled = not _stage1_cleared
	tab1_btn.modulate = Color(1.3, 1.3, 1.0) if _stage_index == 0 else Color(0.7, 0.7, 0.7)
	tab2_btn.modulate = Color(1.0, 1.3, 1.3) if _stage_index == 1 else Color(0.55, 0.55, 0.55)
	if not _stage1_cleared:
		tab2_btn.modulate = Color(0.35, 0.35, 0.35)


func _rebuild_markers() -> void:
	for c in waypoint_layer.get_children():
		c.queue_free()
	for c in ghost_layer.get_children():
		c.queue_free()
	for c in obstacle_layer.get_children():
		c.queue_free()
	for c in hazard_layer.get_children():
		c.queue_free()

	var tint: float = float(_stage()["tint_deg"])
	for rect in _stage()["obstacles"]:
		var r: Rect2 = rect
		var spr := Sprite2D.new()
		var t: Texture2D = _tex.get("obstacle") as Texture2D
		if t:
			spr.texture = t
			if _chroma_mat:
				spr.material = _chroma_mat
			var tex_sz: Vector2 = t.get_size()
			spr.scale = Vector2(r.size.x / tex_sz.x, r.size.y / tex_sz.y)
		spr.centered = true
		spr.position = r.get_center()
		spr.modulate = _hue_mod(tint, 1.0)
		obstacle_layer.add_child(spr)
		# Hitbox stays rect — sprite scaled to rect (plan §5).

	for i in _waypoints.size():
		var wp := Sprite2D.new()
		_apply_sprite(wp, "waypoint", 28.0)
		wp.position = _waypoints[i]
		wp.name = "WP_%d" % i
		wp.set_meta("index", i)
		waypoint_layer.add_child(wp)

	if _hint_level >= 3:
		for gp in _stage()["ghost"]:
			var g := Sprite2D.new()
			_apply_sprite(g, "waypoint", 24.0)
			g.position = gp
			g.modulate = _hue_mod(260.0, 0.35)
			ghost_layer.add_child(g)

	if _hint_level >= 2:
		for rect in _stage()["obstacles"]:
			var r: Rect2 = rect
			var pad := 18.0
			var clear_r := r.grow(pad)
			var hs := Sprite2D.new()
			var ht: Texture2D = _tex.get("hazard") as Texture2D
			if ht:
				hs.texture = ht
				if _chroma_mat:
					hs.material = _chroma_mat
				var tsz: Vector2 = ht.get_size()
				hs.scale = Vector2(clear_r.size.x / tsz.x, clear_r.size.y / tsz.y)
			hs.centered = true
			hs.position = clear_r.get_center()
			hs.modulate = _hue_mod(260.0, 0.45)
			hs.z_index = -1
			hazard_layer.add_child(hs)


func _hue_mod(degrees: float, alpha: float) -> Color:
	## Approximate CSS hue-rotate via HSV shift of a base cyan/amber tint.
	var base := Color(0.85, 0.9, 1.0, alpha)
	if absf(degrees) < 0.01:
		return Color(1, 1, 1, alpha)
	var h: float = fposmod(degrees / 360.0, 1.0)
	return Color.from_hsv(h, 0.55, 1.0, alpha)


func _process(delta: float) -> void:
	_glow_timer += delta
	if _glow_timer >= 0.12:
		_glow_timer = 0.0
		_glow_frame = 1 - _glow_frame
		if beam_head.visible:
			var key := "beam_glow_01" if _glow_frame == 0 else "beam_glow_02"
			_apply_sprite(beam_head, key, 28.0)
	_update_particles(delta)
	if _firing:
		_step_fire(delta)
	_update_waypoint_visuals()
	_update_sensor_visuals()
	_draw_beam_preview()


func _update_waypoint_visuals() -> void:
	_compute_bends()
	var kids := waypoint_layer.get_children()
	for i in kids.size():
		var spr: Sprite2D = kids[i] as Sprite2D
		if spr == null or i >= _waypoints.size():
			continue
		spr.position = _waypoints[i]
		var ok: bool = i < _bend_ok.size() and _bend_ok[i]
		var base_size := 32.0 if i == _dragging else 28.0
		_set_sprite_size(spr, base_size)
		if i == _dragging:
			spr.modulate = Color(1.25, 1.25, 1.05)
		elif _firing or _fire_done:
			spr.modulate = _hue_mod(110.0, 1.0) if ok else _hue_mod(35.0, 1.0)
		else:
			spr.modulate = Color.WHITE


func _set_sprite_size(spr: Sprite2D, display_size: float) -> void:
	if spr == null or spr.texture == null:
		return
	var sz: Vector2 = spr.texture.get_size()
	var s: float = display_size / maxf(sz.x, sz.y)
	spr.scale = Vector2(s, s)


func _update_sensor_visuals() -> void:
	var blocked := _compute_blocked()
	if _fire_done and _fire_fail_at < 0.0:
		_set_sprite_size(sensor, 64.0)
		sensor.modulate = _hue_mod(110.0, 1.0)
	elif not blocked and not _firing:
		_set_sprite_size(sensor, 56.0)
		sensor.modulate = Color(1.2, 1.2, 1.2)
	else:
		_set_sprite_size(sensor, 56.0)
		sensor.modulate = Color.WHITE


func _gui_input(event: InputEvent) -> void:
	if _locked or _firing:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		var local := _to_field(mb.position)
		if mb.pressed:
			_dragging = _hit_waypoint(local)
			if _dragging >= 0:
				_push_undo()
				_drag_offset = _waypoints[_dragging] - local
				accept_event()
		else:
			if _dragging >= 0:
				_dragging = -1
				_refresh_status()
				accept_event()
	elif event is InputEventMouseMotion and _dragging >= 0:
		var mm := event as InputEventMouseMotion
		var local := _to_field(mm.position)
		_waypoints[_dragging] = _clamp_field(local + _drag_offset)
		_refresh_status()
		accept_event()


func _to_field(screen_pos: Vector2) -> Vector2:
	return playfield.get_global_transform_with_canvas().affine_inverse() * screen_pos


func _clamp_field(p: Vector2) -> Vector2:
	return Vector2(clampf(p.x, 20.0, FIELD_SIZE.x - 20.0), clampf(p.y, 20.0, FIELD_SIZE.y - 20.0))


func _hit_waypoint(local: Vector2) -> int:
	for i in range(_waypoints.size() - 1, -1, -1):
		if _waypoints[i].distance_to(local) <= 22.0:
			return i
	return -1


func _path_points() -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.append(_stage()["emitter"] as Vector2)
	for w in _waypoints:
		pts.append(w)
	pts.append(_stage()["sensor"] as Vector2)
	return pts


func _turn_and_incidence(prev: Vector2, curr: Vector2, next: Vector2) -> Dictionary:
	## Godot equivalent of turnAndIncidence().
	## Incidence from cladding normal ≈ 90° − turn/2; TIR requires incidence ≥ θc.
	var a: Vector2 = (curr - prev)
	var b: Vector2 = (next - curr)
	if a.length_squared() < 0.0001 or b.length_squared() < 0.0001:
		return {"turn": 0.0, "incidence": 90.0}
	a = a.normalized()
	b = b.normalized()
	var d: float = clampf(a.dot(b), -1.0, 1.0)
	var turn_rad: float = acos(d)
	var turn_deg: float = rad_to_deg(turn_rad)
	var incidence: float = 90.0 - turn_deg * 0.5
	return {"turn": turn_deg, "incidence": incidence}


func _seg_intersects_rect(a: Vector2, b: Vector2, r: Rect2) -> bool:
	## Godot equivalent of segIntersectsRect() — thick segment vs AABB.
	if r.has_point(a) or r.has_point(b):
		return true
	var corners := [
		r.position,
		r.position + Vector2(r.size.x, 0),
		r.position + r.size,
		r.position + Vector2(0, r.size.y),
	]
	for i in 4:
		if Geometry2D.segment_intersects_segment(a, b, corners[i], corners[(i + 1) % 4]) != null:
			return true
	# Sample along segment for thick collision feel
	var steps := 12
	for s in steps + 1:
		var p: Vector2 = a.lerp(b, float(s) / float(steps))
		if r.grow(2.0).has_point(p):
			return true
	return false


func _compute_bends() -> void:
	## Godot equivalent of computeBends().
	_bend_ok.clear()
	var pts := _path_points()
	var tc: float = float(_stage()["critical_angle"])
	for i in range(1, pts.size() - 1):
		var info: Dictionary = _turn_and_incidence(pts[i - 1], pts[i], pts[i + 1])
		_bend_ok.append(float(info["incidence"]) + 0.01 >= tc)


func _compute_blocked() -> bool:
	## Godot equivalent of computeBlocked().
	_compute_bends()
	for ok in _bend_ok:
		if not ok:
			return true
	var pts := _path_points()
	for i in range(pts.size() - 1):
		for rect in _stage()["obstacles"]:
			if _seg_intersects_rect(pts[i], pts[i + 1], rect as Rect2):
				return true
	return false


func _fail_distance() -> float:
	## Distance along path where failure occurs (-1 = none).
	_compute_bends()
	var pts := _path_points()
	var dist := 0.0
	var tc: float = float(_stage()["critical_angle"])
	for i in range(pts.size() - 1):
		# Fail at waypoint bend when arriving at pts[i] (i is a waypoint index in path).
		if i >= 1 and i <= _waypoints.size():
			var info: Dictionary = _turn_and_incidence(pts[i - 1], pts[i], pts[i + 1])
			if float(info["incidence"]) + 0.01 < tc:
				return dist
		var seg_len: float = pts[i].distance_to(pts[i + 1])
		for rect in _stage()["obstacles"]:
			if _seg_intersects_rect(pts[i], pts[i + 1], rect as Rect2):
				return dist + seg_len * 0.45
		dist += seg_len
	return -1.0


func _refresh_status() -> void:
	var blocked := _compute_blocked()
	if status_icon:
		if blocked:
			status_icon.modulate = _hue_mod(35.0, 1.0)
		else:
			status_icon.modulate = _hue_mod(110.0, 1.0)
	if status_label:
		if blocked:
			status_label.text = "PATH BLOCKED — adjust waypoints (incidence ≥ θc, avoid obstacles)"
			status_label.modulate = Color(1.0, 0.75, 0.35)
		else:
			status_label.text = "ROUTE ARMED — press FIRE to send the beam"
			status_label.modulate = Color(0.55, 1.0, 0.7)
	if _hint_level >= 1 and status_label:
		status_label.text += "\nHint: " + str(_stage().get("hint1", ""))


func _redraw_static() -> void:
	_rebuild_markers()


func _draw_beam_preview() -> void:
	# Clear old segment sprites
	for c in beam_layer.get_children():
		c.queue_free()
	var pts := _path_points()
	var blocked := _compute_blocked()
	var col := Color(0.35, 0.85, 1.0, 0.55) if not blocked else Color(1.0, 0.55, 0.25, 0.45)
	if _firing or _fire_done:
		col = Color(0.4, 1.0, 0.85, 0.9) if _fire_fail_at < 0.0 else Color(1.0, 0.4, 0.2, 0.85)
	var t: Texture2D = _tex.get("beam_segment") as Texture2D
	var draw_to := pts.size() - 1
	var max_dist := _total_len
	if _firing:
		max_dist = _beam_progress
	elif _fire_done and _fire_fail_at >= 0.0:
		max_dist = _fire_fail_at
	elif _fire_done:
		max_dist = _total_len
	else:
		max_dist = _total_len # preview full
	var traveled := 0.0
	for i in range(draw_to):
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		var seg: float = a.distance_to(b)
		if seg < 1.0:
			continue
		var end_p: Vector2 = b
		if traveled + seg > max_dist and (_firing or (_fire_done and _fire_fail_at >= 0.0)):
			var u: float = clampf((max_dist - traveled) / seg, 0.0, 1.0)
			end_p = a.lerp(b, u)
			_add_beam_seg(a, end_p, t, col)
			break
		_add_beam_seg(a, end_p, t, col)
		traveled += seg
		if not _firing and not _fire_done:
			pass


func _add_beam_seg(a: Vector2, b: Vector2, tex: Texture2D, col: Color) -> void:
	var mid: Vector2 = (a + b) * 0.5
	var length: float = a.distance_to(b)
	var ang: float = (b - a).angle()
	if tex:
		var spr := Sprite2D.new()
		spr.texture = tex
		if _chroma_mat:
			spr.material = _chroma_mat
		spr.centered = true
		spr.position = mid
		spr.rotation = ang - PI * 0.5
		var tsz: Vector2 = tex.get_size()
		spr.scale = Vector2(10.0 / tsz.x, length / tsz.y)
		spr.modulate = col
		beam_layer.add_child(spr)
	else:
		var line := Line2D.new()
		line.width = 4.0
		line.default_color = col
		line.add_point(a)
		line.add_point(b)
		beam_layer.add_child(line)


func _push_undo() -> void:
	var snap: Array = []
	for w in _waypoints:
		snap.append(w)
	_undo_stack.append(snap)
	if _undo_stack.size() > 40:
		_undo_stack.pop_front()


func _on_undo() -> void:
	if _locked or _firing or _undo_stack.is_empty():
		return
	var snap: Array = _undo_stack.pop_back()
	_waypoints.clear()
	for p in snap:
		_waypoints.append(p as Vector2)
	_rebuild_markers()
	_refresh_status()


func _on_clear() -> void:
	if _locked or _firing:
		return
	_push_undo()
	_waypoints.clear()
	for p in _stage()["waypoints"]:
		_waypoints.append(p as Vector2)
	_hint_level = 0
	_fire_done = false
	_fire_fail_at = -1.0
	_rebuild_markers()
	_refresh_status()


func _on_hint(level: int) -> void:
	if _locked or _firing:
		return
	_hint_level = maxi(_hint_level, level)
	_rebuild_markers()
	_refresh_status()


func _on_tab(idx: int) -> void:
	if _locked or _firing:
		return
	if idx == 1 and not _stage1_cleared:
		status_label.text = "Clear SERVER ROOM before unlocking TRANSOCEANIC CABLE."
		return
	if idx == _stage_index:
		return
	_enter_stage(idx, true)


func _on_fire() -> void:
	if _locked or _firing:
		return
	_fire_done = false
	_particles.clear()
	_path_cache = _path_points()
	_rebuild_path_lengths()
	_fire_fail_at = _fail_distance()
	_beam_progress = 0.0
	_firing = true
	_locked = true
	beam_head.visible = true
	status_label.text = "FIRING…"
	status_label.modulate = Color(0.7, 0.9, 1.0)


func _rebuild_path_lengths() -> void:
	_path_lengths = PackedFloat32Array()
	_total_len = 0.0
	for i in range(_path_cache.size() - 1):
		var L: float = _path_cache[i].distance_to(_path_cache[i + 1])
		_path_lengths.append(L)
		_total_len += L


func _point_at(dist: float) -> Vector2:
	var d := dist
	for i in range(_path_cache.size() - 1):
		var L: float = _path_lengths[i]
		if d <= L:
			return _path_cache[i].lerp(_path_cache[i + 1], d / maxf(L, 0.001))
		d -= L
	return _path_cache[_path_cache.size() - 1]


func _step_fire(delta: float) -> void:
	var speed := 420.0
	_beam_progress += speed * delta
	var stop_at: float = _total_len
	if _fire_fail_at >= 0.0:
		stop_at = _fire_fail_at
	var p: Vector2 = _point_at(minf(_beam_progress, stop_at))
	beam_head.position = p
	if _beam_progress >= stop_at:
		_firing = false
		_fire_done = true
		if _fire_fail_at >= 0.0:
			_spawn_leak(p)
			_on_fail_route()
		else:
			_spawn_success_sparks(sensor.position)
			_on_success_route()


func _spawn_leak(at: Vector2) -> void:
	for i in 14:
		_particles.append({
			"pos": at,
			"vel": Vector2(randf_range(-120, 120), randf_range(-160, 40)),
			"life": 1.0,
			"success": false,
		})


func _spawn_success_sparks(at: Vector2) -> void:
	for i in 18:
		_particles.append({
			"pos": at,
			"vel": Vector2(randf_range(-90, 90), randf_range(-120, 60)),
			"life": 1.0,
			"success": true,
		})


func _update_particles(delta: float) -> void:
	for c in particle_layer.get_children():
		c.queue_free()
	var next: Array = []
	for pt in _particles:
		pt["life"] = float(pt["life"]) - delta * 1.2
		pt["vel"] = pt["vel"] + Vector2(0, 180.0) * delta
		pt["pos"] = pt["pos"] + pt["vel"] * delta
		if float(pt["life"]) > 0.0:
			next.append(pt)
			var spr := Sprite2D.new()
			var t: Texture2D = _tex.get("particle") as Texture2D
			if t:
				spr.texture = t
				if _chroma_mat:
					spr.material = _chroma_mat
				spr.scale = Vector2(0.04, 0.04)
			spr.centered = true
			spr.position = pt["pos"]
			var life: float = float(pt["life"])
			if pt["success"]:
				spr.modulate = _hue_mod(110.0, life)
			else:
				spr.modulate = _hue_mod(35.0, life)
			particle_layer.add_child(spr)
	_particles = next


func _on_fail_route() -> void:
	beam_head.visible = false
	if status_icon:
		status_icon.modulate = _hue_mod(35.0, 1.0)
	status_label.text = "SIGNAL LOST — beam leaked or hit an obstacle"
	status_label.modulate = Color(1.0, 0.45, 0.35)
	result_layer.visible = true
	result_label.text = "ROUTE FAILED\nAdjust waypoints and retry.\nZone 04 stays locked."
	result_btn.text = "RETRY"
	result_btn.set_meta("mode", "retry")
	_locked = true


func _on_success_route() -> void:
	beam_head.visible = true
	beam_head.position = sensor.position
	if status_icon:
		status_icon.modulate = _hue_mod(110.0, 1.0)
	if _stage_index == 0:
		_stage1_cleared = true
		status_label.text = "SERVER ROOM CLEAR — Transoceanic Cable unlocked"
		status_label.modulate = Color(0.5, 1.0, 0.7)
		result_layer.visible = true
		result_label.text = "STAGE 1 COMPLETE\nSERVER ROOM signal locked.\nProceed to TRANSOCEANIC CABLE."
		result_btn.text = "CONTINUE TO STAGE 2"
		result_btn.set_meta("mode", "stage2")
		_locked = true
	else:
		status_label.text = "TRANSOCEANIC LINK ESTABLISHED"
		status_label.modulate = Color(0.5, 1.0, 0.7)
		result_layer.visible = true
		result_label.text = "FIBER ESCAPE COMPLETE\nZone 03 mini-game successful.\nZone 04 unlocked on the World Map."
		result_btn.text = "RETURN TO WORLD MAP"
		result_btn.set_meta("mode", "world")
		_locked = true
		GameState.mark_minigame_successful(GameState.ZONE_03)


func _on_result_btn() -> void:
	var mode := str(result_btn.get_meta("mode", "retry"))
	result_layer.visible = false
	if mode == "retry":
		_locked = false
		_firing = false
		_fire_done = false
		_fire_fail_at = -1.0
		_particles.clear()
		beam_head.visible = false
		_refresh_status()
	elif mode == "stage2":
		_enter_stage(1, true)
	elif mode == "world":
		if SceneTransition.is_busy():
			await SceneTransition.transition_finished
		SceneTransition.change_to(WORLD_MAP_PATH)

extends SceneTree
## Verify Zone 03 Fiber Escape mini-game wiring.
## Run:
##   Godot_v4.7.1-stable_win64_console.exe --path "d:\capstone 2" --headless --script res://scripts/tools/verify_mg03_fiber_escape.gd


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await process_frame
	var fail := 0

	fail += _ok(ResourceLoader.exists("res://scenes/minigames/zone03/MiniGame03_FiberEscape.tscn"), "MG3 scene")
	fail += _ok(ResourceLoader.exists("res://scripts/minigames/zone03/MiniGame03FiberEscape.gd"), "MG3 script")
	fail += _ok(ResourceLoader.exists("res://shaders/chroma_key_jpg.gdshader"), "chroma shader")

	var base := "res://asset/minigame asset/zone 3 mini game/mini game 3 asset/"
	var assets := [
		"beam_glow_01.jpg", "beam_glow_02.jpg", "beam_segment_tile.jpg", "emitter.jpg",
		"favicon.jpg", "hazard_stripe_tile.jpg", "Icon_clear.jpg", "icon_fire.jpg",
		"icon_hint.jpg", "icon_status.jpg", "icon_tab.jpg", "icon_undo.jpg",
		"obstacle_block.jpg", "particle.jpg", "Sensor_ring.jpg", "waypoint.jpg",
	]
	for a in assets:
		fail += _ok(ResourceLoader.exists(base + a), "asset " + a)

	var src := FileAccess.get_file_as_string("res://scripts/minigames/zone03/MiniGame03FiberEscape.gd")
	fail += _ok(src.find("extends Control") == 0 or src.contains("extends Control"), "extends Control")
	fail += _ok(not src.contains("extends MiniGameBase") and not src.contains("MiniGameBase"), "no MiniGameBase")
	fail += _ok(not src.contains(".png"), "no bogus .png asset refs")
	fail += _ok(src.contains("Sensor_ring.jpg"), "Sensor_ring.jpg casing")
	fail += _ok(src.contains("Icon_clear.jpg"), "Icon_clear.jpg casing")
	fail += _ok(src.contains("critical_angle\": 55.0") or src.contains("\"critical_angle\": 55.0"), "stage1 55")
	fail += _ok(src.contains("68.0"), "stage2 68")
	fail += _ok(src.contains("SERVER ROOM"), "SERVER ROOM")
	fail += _ok(src.contains("TRANSOCEANIC"), "TRANSOCEANIC")
	fail += _ok(src.contains("mark_minigame_successful(GameState.ZONE_03)"), "marks ZONE_03 on final success")
	fail += _ok(src.contains("_stage_index == 0"), "stage1 does not final-mark alone")
	fail += _ok(src.contains("_on_fail_route") or src.contains("ROUTE FAILED"), "failure path")
	fail += _ok(src.contains("RETRY"), "retry")
	fail += _ok(src.contains("_turn_and_incidence") and src.contains("_seg_intersects_rect"), "routing math")
	fail += _ok(src.contains("_compute_bends") and src.contains("_compute_blocked"), "bend/blocked")
	fail += _ok(not src.contains("Lab Bench") and not src.contains("LAB BENCH"), "no Lab Bench stage")

	var floor4 := FileAccess.get_file_as_string("res://scripts/zone03/Zone03Floor4.gd")
	fail += _ok(floor4.contains("MiniGame03_FiberEscape.tscn"), "Floor4 launches MG3")
	fail += _ok(not floor4.contains("mark_minigame_successful(GameState.ZONE_03)"), "Floor4 no fake SUCCESSFUL mark")

	# Ensure Z01/Z02 not broken by accidental edits (presence only)
	fail += _ok(ResourceLoader.exists("res://scenes/minigames/zone01/MiniGame01_Brake.tscn"), "Z01 MG intact")

	var ps: PackedScene = load("res://scenes/minigames/zone03/MiniGame03_FiberEscape.tscn")
	fail += _ok(ps != null, "scene loads")
	if ps:
		var n: Node = ps.instantiate()
		fail += _ok(n.get_node_or_null("Playfield/Emitter") != null, "Emitter")
		fail += _ok(n.get_node_or_null("Playfield/Sensor") != null, "Sensor")
		fail += _ok(n.get_node_or_null("Playfield/WaypointLayer") != null, "WaypointLayer")
		fail += _ok(n.get_node_or_null("Playfield/ObstacleLayer") != null, "ObstacleLayer")
		fail += _ok(n.get_node_or_null("HUD/Buttons/FireButton") != null, "FireButton")
		fail += _ok(n.get_node_or_null("HUD/Buttons/UndoButton") != null, "UndoButton")
		fail += _ok(n.get_node_or_null("HUD/Buttons/ClearButton") != null, "ClearButton")
		fail += _ok(n.get_node_or_null("HUD/Buttons/Hint1Button") != null, "Hint1")
		fail += _ok(n.get_node_or_null("HUD/Buttons/Hint2Button") != null, "Hint2")
		fail += _ok(n.get_node_or_null("HUD/Buttons/Hint3Button") != null, "Hint3")
		fail += _ok(n.get_node_or_null("ResultLayer") != null, "ResultLayer")
		# Instantiating runs _ready which needs GameState autoload — OK in project --script run
		n.free()

	# Logic spot-check: ghost routes must clear; default Stage layouts must be blocked.
	fail += _ok(_route_ok(
		[Vector2(70, 240), Vector2(280, 80), Vector2(560, 80), Vector2(730, 240)],
		[Rect2(340, 180, 100, 140), Rect2(300, 340, 200, 80)],
		55.0
	), "Stage1 ghost solvable")
	fail += _ok(not _route_ok(
		[Vector2(70, 240), Vector2(300, 280), Vector2(520, 380), Vector2(730, 240)],
		[Rect2(340, 180, 100, 140), Rect2(300, 340, 200, 80)],
		55.0
	), "Stage1 default blocked")
	fail += _ok(_route_ok(
		[Vector2(60, 60), Vector2(250, 50), Vector2(450, 50), Vector2(650, 50), Vector2(740, 80)],
		[Rect2(180, 120, 80, 200), Rect2(360, 160, 100, 200), Rect2(540, 120, 80, 220)],
		68.0
	), "Stage2 ghost solvable")
	fail += _ok(not _route_ok(
		[Vector2(60, 60), Vector2(220, 300), Vector2(420, 300), Vector2(600, 300), Vector2(740, 80)],
		[Rect2(180, 120, 80, 200), Rect2(360, 160, 100, 200), Rect2(540, 120, 80, 220)],
		68.0
	), "Stage2 default blocked")

	print("VERIFY_MG3 fail=", fail)
	quit(0 if fail == 0 else 1)


func _incidence(prev: Vector2, curr: Vector2, next: Vector2) -> float:
	var a: Vector2 = (curr - prev).normalized()
	var b: Vector2 = (next - curr).normalized()
	var turn_deg: float = rad_to_deg(acos(clampf(a.dot(b), -1.0, 1.0)))
	return 90.0 - turn_deg * 0.5


func _seg_hits(a: Vector2, b: Vector2, r: Rect2) -> bool:
	for s in 41:
		var p: Vector2 = a.lerp(b, float(s) / 40.0)
		if r.grow(2.0).has_point(p):
			return true
	return false


func _route_ok(pts: Array, obstacles: Array, tc: float) -> bool:
	for i in range(1, pts.size() - 1):
		if _incidence(pts[i - 1], pts[i], pts[i + 1]) + 0.01 < tc:
			return false
	for i in range(pts.size() - 1):
		for r in obstacles:
			if _seg_hits(pts[i], pts[i + 1], r):
				return false
	return true


func _ok(cond: bool, msg: String) -> int:
	if cond:
		print("  OK  ", msg)
		return 0
	print("  FAIL ", msg)
	return 1

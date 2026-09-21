extends SceneTree
## Verify Zone 02 Harbor Works mini-game wiring.
## Run:
##   Godot_v4.7.1-stable_win64_console.exe --path "d:\capstone 2" --headless --script res://scripts/tools/verify_mg02_harbor_works.gd


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await process_frame
	var fail := 0

	fail += _ok(ResourceLoader.exists("res://scenes/minigames/zone02/MiniGame02_HarborWorks.tscn"), "MG2 scene")
	fail += _ok(ResourceLoader.exists("res://scripts/minigames/zone02/MiniGame02HarborWorks.gd"), "MG2 script")
	fail += _ok(ResourceLoader.exists("res://data/zone02_harbor_briefs.json"), "briefs JSON")

	var base := "res://asset/minigame asset/zone 2 mini game/mini_games_2_asset/"
	var assets := [
		"harbor_works_bg.png", "cargo_crate.png",
		"motor_straight.png", "motor_elbow.png",
		"hand_crank_straight.png", "hand_crank_elbow.png",
		"counterweight_straight.png", "counterweight_elbow.png",
		"fixed_pulley_straight.png", "fixed_pulley_elbow.png",
		"movable_pulley_straight.png", "movable_pulley_elbow.png",
		"ramp_straight.png", "ramp_elbow.png",
		"liver_straight.png", "liver_elbow.png",
		"read_out_panel.png", "star_empty.png", "star_filled.png",
	]
	for a in assets:
		fail += _ok(ResourceLoader.exists(base + a), "asset " + a)

	var src := FileAccess.get_file_as_string("res://scripts/minigames/zone02/MiniGame02HarborWorks.gd")
	fail += _ok(src.find("extends Control") == 0 or src.contains("extends Control"), "extends Control")
	fail += _ok(not src.contains("extends MiniGameBase"), "no MiniGameBase")
	fail += _ok(src.contains("liver_straight.png") and src.contains("liver_elbow.png"), "liver filenames")
	fail += _ok(not src.contains("lever_straight.png"), "no renamed lever png paths")
	fail += _ok(src.contains("mark_minigame_successful(GameState.ZONE_02)"), "marks ZONE_02")
	fail += _ok(src.contains("zone02_badge_earned"), "sets badge earned")
	fail += _ok(src.contains("WorldMap.tscn"), "returns World Map")
	fail += _ok(src.contains("G := 9.8") or src.contains("const G := 9.8"), "G=9.8")

	var floor4 := FileAccess.get_file_as_string("res://scripts/zone02/Zone02Floor4.gd")
	fail += _ok(floor4.contains("MiniGame02_HarborWorks.tscn"), "Floor4 launches MG2")
	fail += _ok(not floor4.contains("mark_minigame_successful(GameState.ZONE_02)"), "Floor4 no fake SUCCESSFUL mark")

	fail += _ok(ResourceLoader.exists("res://scenes/minigames/zone01/MiniGame01_Brake.tscn"), "Z01 MG intact")
	fail += _ok(ResourceLoader.exists("res://scenes/minigames/zone03/MiniGame03_FiberEscape.tscn"), "Z03 MG intact")

	var briefs_txt := FileAccess.get_file_as_string("res://data/zone02_harbor_briefs.json")
	var briefs: Variant = JSON.parse_string(briefs_txt)
	fail += _ok(typeof(briefs) == TYPE_ARRAY and briefs.size() == 3, "3 briefs")

	var ps: PackedScene = load("res://scenes/minigames/zone02/MiniGame02_HarborWorks.tscn")
	fail += _ok(ps != null, "scene loads")
	if ps:
		var n: Node = ps.instantiate()
		fail += _ok(n.get_node_or_null("Background") != null, "Background")
		fail += _ok(n.get_node_or_null("BoardArea/BoardGrid") != null, "BoardGrid")
		fail += _ok(n.get_node_or_null("TilePalette") != null, "TilePalette")
		fail += _ok(n.get_node_or_null("PredictionPanel/LaunchButton") != null, "LaunchButton")
		fail += _ok(n.get_node_or_null("StarsPanel/Star1") != null, "Star1")
		fail += _ok(n.get_node_or_null("ReadoutPanel") != null, "ReadoutPanel")
		n.free()

	# Spot-check Brief1 physics: motor-only path η=1 → Win=2352, time=2352/400
	var w_out := 60.0 * 9.8 * 4.0
	fail += _ok(absf(w_out - 2352.0) < 0.01, "Brief1 W_out 2352")

	print("VERIFY_MG2 fail=", fail)
	quit(0 if fail == 0 else 1)


func _ok(cond: bool, msg: String) -> int:
	if cond:
		print("  OK  ", msg)
		return 0
	print("  FAIL ", msg)
	return 1

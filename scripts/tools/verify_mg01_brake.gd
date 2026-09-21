extends SceneTree
## Verify Zone 01 Emergency Brake mini-game wiring.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await process_frame
	var fail := 0
	fail += _ok(ResourceLoader.exists("res://scenes/minigames/zone01/MiniGame01_Brake.tscn"), "MG1 scene")
	fail += _ok(ResourceLoader.exists("res://scripts/minigames/zone01/MiniGame01Brake.gd"), "MG1 script")
	fail += _ok(ResourceLoader.exists("res://data/zone01_minigames.json"), "MG1 JSON")
	var assets := [
		"mg01_brake_bg.png", "mg01_steel_block.png", "button_yes.png", "button_no.png",
		"countdown_bar.png", "force_option_button.png", "reference_card_friction.png",
		"crash_burst_spritesheet.png",
	]
	var base := "res://asset/minigame asset/zone 1 mini game/mini game 1 asset/"
	for a in assets:
		fail += _ok(ResourceLoader.exists(base + a), "asset " + a)

	var src := FileAccess.get_file_as_string("res://scripts/minigames/zone01/MiniGame01Brake.gd")
	fail += _ok(not src.contains("extends MiniGame"), "self-contained extends Control")
	fail += _ok(src.begins_with("extends Control") or src.contains("\nextends Control") or src.find("extends Control") == 0, "extends Control")
	fail += _ok(not src.contains("Zone01_Factory"), "no Zone01_Factory path")
	fail += _ok(src.contains("mark_minigame_successful"), "calls GameState success")
	fail += _ok(src.contains("FACTORY DAMAGED"), "fail overlay")

	var floor4 := FileAccess.get_file_as_string("res://scripts/zone01/Zone01Floor4.gd")
	fail += _ok(floor4.contains("MiniGame01_Brake.tscn"), "Floor4 launches MG1")
	fail += _ok(not floor4.contains("mark_minigame_successful(GameState.ZONE_01)"), "Floor4 no fake SUCCESSFUL mark")

	var ps: PackedScene = load("res://scenes/minigames/zone01/MiniGame01_Brake.tscn")
	fail += _ok(ps != null, "scene loads")
	if ps:
		var n: Node = ps.instantiate()
		fail += _ok(n.get_node_or_null("Background") != null, "Background")
		fail += _ok(n.get_node_or_null("BlockSprite") != null, "BlockSprite")
		fail += _ok(n.get_node_or_null("CrashBurst") != null, "CrashBurst")
		fail += _ok(n.get_node_or_null("HUD/YesButton") != null, "YesButton")
		fail += _ok(n.get_node_or_null("HUD/NoButton") != null, "NoButton")
		fail += _ok(n.get_node_or_null("HUD/ForceBox/Force1") != null, "Force1")
		fail += _ok(n.get_node_or_null("HUD/CountdownBar") != null, "CountdownBar")
		fail += _ok(n.get_node_or_null("HUD/ReferenceCard") != null, "ReferenceCard")
		fail += _ok(n.get_node_or_null("GameOverLayer") != null, "GameOverLayer")
		n.free()

	# JSON physics spot-check vs spec example (μ=0.35, m=40 → friction 140; extra 220)
	var f := FileAccess.open("res://data/zone01_minigames.json", FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())
	f.close()
	var no1: Dictionary = data["minigames"]["mg01_brake"]["no_scenarios"][0]
	var friction: float = float(no1["mu"]) * float(no1["block_mass_kg"]) * 10.0
	var extra: int = int(no1["required_stop_force_n"]) - int(friction)
	fail += _ok(extra == int(no1["correct_additional_force_n"]), "JSON force math no1")

	print("VERIFY_MG1 fail=", fail)
	quit(0 if fail == 0 else 1)


func _ok(cond: bool, msg: String) -> int:
	if cond:
		print("  OK  ", msg)
		return 0
	print("  FAIL ", msg)
	return 1

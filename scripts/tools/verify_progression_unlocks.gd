extends SceneTree
## End-to-end: Floor4 pass + mini-game SUCCESSFUL unlocks next zone; quiz alone does not.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Progression unlock verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	_expect(gs != null, "GameState")
	if gs:
		gs.reset_progress_flags()

	# Zone 01: quiz alone does not unlock Z02
	var z1: Node = (load("res://scenes/zone01/Zone01_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(z1)
	await process_frame
	await process_frame
	_expect(z1.get_node_or_null("DemoCompleteUI") != null, "Z01 DemoCompleteUI")
	_expect(z1.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame1Button") != null, "Z01 PLAY")
	_expect(z1.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/ReturnToWorldMapButton") != null, "Z01 RETURN")
	z1._on_quiz_continue()
	await process_frame
	_expect(gs.zone01_floor4_passed, "Z01 F4 passed")
	_expect(not gs.zone01_minigame_successful, "Z01 MG not yet")
	_expect(not gs.is_zone_unlocked(gs.ZONE_02), "Z02 locked after Z01 quiz only")
	z1._on_play_mg1()
	await process_frame
	_expect(gs.zone01_minigame_successful, "Z01 MG successful")
	_expect(gs.is_zone_unlocked(gs.ZONE_02), "Z02 unlocked after Z01 MG")
	var ret1: Button = z1.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/ReturnToWorldMapButton") as Button
	_expect(ret1 != null and ret1.visible, "Z01 RETURN visible after SUCCESSFUL")
	z1.queue_free()
	await process_frame

	# Zone 02: quiz alone does NOT unlock Z03 / does NOT set complete
	if gs:
		gs.zone02_floor4_passed = false
		gs.zone02_minigame_successful = false
		gs.zone02_complete = false
	var z2: Node = (load("res://scenes/zone02/Zone02_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(z2)
	await process_frame
	await process_frame
	_expect(z2.get_node_or_null("MiniGameArea") != null, "Z02 MiniGameArea")
	_expect(z2.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame1Button") != null, "Z02 PLAY")
	z2._on_quiz_continue()
	await process_frame
	_expect(gs.zone02_floor4_passed, "Z02 F4 passed")
	_expect(not gs.zone02_complete, "Z02 quiz does not set complete")
	_expect(not gs.zone02_minigame_successful, "Z02 MG not yet")
	_expect(not gs.is_zone_unlocked(gs.ZONE_03), "Z03 locked after Z02 quiz only")
	z2._on_play_mg1()
	await process_frame
	_expect(gs.zone02_minigame_successful, "Z02 MG successful")
	_expect(gs.zone02_complete, "Z02 complete after MG")
	_expect(gs.is_zone_unlocked(gs.ZONE_03), "Z03 unlocked after Z02 MG")
	z2.queue_free()
	await process_frame

	# Zone 03: exactly one PLAY; SUCCESSFUL unlocks Z04
	if gs:
		gs.zone03_floor4_passed = false
		gs.zone03_minigame_successful = false
		gs.zone03_complete = false
	var z3: Node = (load("res://scenes/zone03/Zone03_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(z3)
	await process_frame
	await process_frame
	var play2: CanvasItem = z3.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame2Button") as CanvasItem
	z3._on_quiz_continue()
	await process_frame
	z3._open_placeholder_ui()
	await process_frame
	_expect(play2 == null or play2.visible == false, "Z03 only one PLAY visible")
	_expect(not gs.is_zone_unlocked(gs.ZONE_04), "Z04 locked after Z03 quiz")
	z3._on_play_mg1()
	await process_frame
	_expect(gs.zone03_minigame_successful, "Z03 MG successful")
	_expect(gs.is_zone_unlocked(gs.ZONE_04), "Z04 unlocked after Z03 MG")
	z3.queue_free()
	await process_frame

	# Zone 04 → Zone 05
	if gs:
		gs.zone04_floor4_passed = false
		gs.zone04_minigame_successful = false
		gs.zone04_complete = false
	var z4: Node = (load("res://scenes/zone04/Zone04_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(z4)
	await process_frame
	await process_frame
	z4._on_quiz_continue()
	await process_frame
	_expect(not gs.is_zone_unlocked(gs.ZONE_05), "Z05 locked after Z04 quiz")
	z4._on_play_mg1()
	await process_frame
	_expect(gs.zone04_minigame_successful, "Z04 MG successful")
	_expect(gs.is_zone_unlocked(gs.ZONE_05), "Z05 unlocked after Z04 MG")
	z4.queue_free()
	await process_frame

	# World Map monotonic: unlocked zones stay unlocked on re-apply
	var map: Node = (load("res://scenes/world_map/WorldMap.tscn") as PackedScene).instantiate()
	root.add_child(map)
	await process_frame
	await process_frame
	_expect(gs.is_zone_unlocked(gs.ZONE_02), "Z02 still unlocked")
	_expect(gs.is_zone_unlocked(gs.ZONE_03), "Z03 still unlocked")
	_expect(gs.is_zone_unlocked(gs.ZONE_04), "Z04 still unlocked")
	_expect(gs.is_zone_unlocked(gs.ZONE_05), "Z05 still unlocked")
	map._apply_landmark_states()
	await process_frame
	var z02_click: Area2D = map.get_node_or_null("Landmarks/Zone02_Locked/ClickArea") as Area2D
	_expect(z02_click != null and z02_click.is_locked == false, "Z02 landmark stays unlocked")
	# Z05 click shows coming soon
	var z05_click: Area2D = map.get_node_or_null("Landmarks/Zone05_Locked/ClickArea") as Area2D
	map._on_landmark_clicked(z05_click)
	await process_frame
	var prompt: Label = map.get_node_or_null("UI/PromptLabel") as Label
	_expect(prompt != null and prompt.visible and "coming soon" in prompt.text.to_lower(), "Z05 coming soon")
	map.queue_free()

	# Sync uses floor4 + minigame flags
	var gssrc := FileAccess.get_file_as_string("res://scripts/autoload/GameState.gd")
	_expect(gssrc.contains("zone01_minigame_successful"), "flag Z01 MG")
	_expect(gssrc.contains("zone02_minigame_successful"), "flag Z02 MG")
	_expect(gssrc.contains("zone03_minigame_successful"), "flag Z03 MG")
	_expect(gssrc.contains("zone04_minigame_successful"), "flag Z04 MG")
	_expect(gssrc.contains("mark_minigame_successful"), "mark_minigame_successful")

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_failures += 1
		printerr("FAIL %s" % label)

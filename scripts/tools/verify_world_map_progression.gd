extends SceneTree
## World Map progression — unlock requires Floor4 + mini-game SUCCESSFUL.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== World Map progression verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.reset_progress_flags()

	var map: Node = (load("res://scenes/world_map/WorldMap.tscn") as PackedScene).instantiate()
	root.add_child(map)
	await process_frame
	await process_frame
	var z04_root: Node2D = map.get_node_or_null("Landmarks/Zone04_Locked") as Node2D
	var z04_click: Area2D = map.get_node_or_null("Landmarks/Zone04_Locked/ClickArea") as Area2D
	_expect(z04_root != null and z04_click != null, "Zone04 landmark nodes")
	_expect(bool(z04_click.is_locked) == true, "Zone04 locked before Z03 MG")
	_expect(z04_root.modulate.r < 0.7, "Zone04 shadowed before unlock")
	map.queue_free()
	await process_frame

	if gs:
		gs.zone03_floor4_passed = true
		gs.zone03_minigame_successful = true
		gs.sync_world_map_unlocks()
		_expect(gs.is_zone_unlocked(gs.ZONE_04), "ZONE_04 unlocked with F4+MG")

	map = (load("res://scenes/world_map/WorldMap.tscn") as PackedScene).instantiate()
	root.add_child(map)
	await process_frame
	await process_frame
	z04_root = map.get_node_or_null("Landmarks/Zone04_Locked") as Node2D
	z04_click = map.get_node_or_null("Landmarks/Zone04_Locked/ClickArea") as Area2D
	_expect(bool(z04_click.is_locked) == false, "Zone04 unlocked after MG")
	_expect(is_equal_approx(z04_root.modulate.r, 1.0), "Zone04 full color after unlock")
	map._on_landmark_clicked(z04_click)
	await process_frame
	# Unlocked Z04 enters Exterior (scene exists) — no "coming soon"
	_expect(ResourceLoader.exists("res://scenes/zone04/Zone04_Exterior.tscn"), "Z04 Exterior exists")
	map._apply_landmark_states()
	_expect(bool(z04_click.is_locked) == false, "Zone04 stays unlocked after re-apply")
	map.queue_free()
	await process_frame

	# Quiz alone does not unlock
	if gs:
		gs.reset_progress_flags()
		gs.zone03_floor4_passed = true
	var f4: Node = (load("res://scenes/zone03/Zone03_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(f4)
	await process_frame
	await process_frame
	f4._on_quiz_continue()
	await process_frame
	_expect(not gs.is_zone_unlocked(gs.ZONE_04), "quiz alone does not unlock ZONE_04")
	f4._on_play_mg1()
	await process_frame
	_expect(gs.zone03_minigame_successful, "PLAY sets MG successful")
	_expect(gs.is_zone_unlocked(gs.ZONE_04), "PLAY SUCCESSFUL unlocks ZONE_04")
	f4.queue_free()

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_failures += 1
		printerr("FAIL %s" % label)

extends SceneTree
## Zone 02 Exterior — architecture + monotonic door unlock (no exact layout asserts).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone02 Exterior foundation verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone02_floor1_passed = false
		gs.zone02_floor2_passed = false
		gs.zone02_floor3_passed = false
		gs.zone02_exterior_spawn_marker = ""

	var path := "res://scenes/zone02/Zone02_Exterior.tscn"
	_expect(ResourceLoader.exists(path), "Zone02_Exterior.tscn exists")
	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor1.tscn"), "Floor1 scene exists (Door1 target)")
	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor2.tscn"), "Floor2 scene exists (Door2 target)")
	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor3.tscn"), "Floor3 scene exists (Door3 target)")
	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor4.tscn"), "Floor4 scene exists (final assessment)")

	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var wing: Sprite2D = scene.get_node_or_null("Background/WingArt") as Sprite2D
	_expect(wing != null and wing.texture != null, "Wing background exists")
	if wing and wing.texture:
		_expect(String(wing.texture.resource_path).ends_with("energy_assessment_wing.png"), "uses energy_assessment_wing.png")

	var guide: Node = scene.get_node_or_null("NPCs/Guide")
	_expect(guide is CharacterBody2D, "Guide is CharacterBody2D (NPC)")
	_expect(guide.get_node_or_null("Sprite2D") != null, "Guide has Sprite2D")
	_expect(guide.get_node_or_null("InteractionArea") is Area2D, "Guide InteractionArea")
	_expect(guide.get_node_or_null("InteractionArea/CollisionShape2D") != null, "Guide InteractionArea shape")
	if "can_interact" in guide:
		_expect(bool(guide.can_interact) == false, "Guide can_interact false")

	_expect(scene.get_node_or_null("DialoguePanel") != null, "DialoguePanel")
	_expect(scene.get_node_or_null("Doors/Door1") is Area2D, "Door1")
	_expect(scene.get_node_or_null("Doors/Door2") is Area2D, "Door2")
	_expect(scene.get_node_or_null("Doors/Door3") is Area2D, "Door3")
	_expect(scene.get_node_or_null("Player") is CharacterBody2D, "Player")
	_expect(scene.get_node_or_null("PlayerSpawn") != null, "PlayerSpawn")
	_expect(scene.get_node_or_null("Camera2D") != null, "Camera2D")
	_expect(scene.get_node_or_null("Collision") != null, "Collision root")
	_expect(scene.get_node_or_null("Floor1ReturnSpawn") != null, "Floor1ReturnSpawn")
	_expect(scene.get_node_or_null("Floor2ReturnSpawn") != null, "Floor2ReturnSpawn")
	_expect(scene.get_node_or_null("Floor3ReturnSpawn") != null, "Floor3ReturnSpawn")

	# Initial locked state
	_expect(bool(scene.get("_door1_available")) == true, "Door1 available")
	_expect(bool(scene.get("_door2_locked")) == true, "Door2 locked initially")
	_expect(bool(scene.get("_door3_locked")) == true, "Door3 locked initially")

	# After Floor1: Door2 unlocks, Door3 stays locked
	if gs:
		gs.zone02_floor1_passed = true
	scene._apply_door_lock_state()
	_expect(bool(scene.get("_door1_available")) == true, "Door1 stays available after F1")
	_expect(bool(scene.get("_door2_locked")) == false, "Door2 unlocked after F1")
	_expect(bool(scene.get("_door3_locked")) == true, "Door3 locked after F1")
	var lv2: CanvasItem = scene.get_node_or_null("Doors/Door2/LockedVisual") as CanvasItem
	_expect(lv2 == null or lv2.visible == false, "Door2 LockedVisual hidden after F1")

	# After Floor2: Door2 AND Door3 unlocked (Door2 must NOT re-lock)
	if gs:
		gs.zone02_floor2_passed = true
	scene._apply_door_lock_state()
	_expect(bool(scene.get("_door1_available")) == true, "Door1 stays available after F2")
	_expect(bool(scene.get("_door2_locked")) == false, "Door2 stays unlocked after F2")
	_expect(bool(scene.get("_door3_locked")) == false, "Door3 unlocked after F2")
	_expect(lv2 == null or lv2.visible == false, "Door2 LockedVisual stays hidden after F2")
	var lv3: CanvasItem = scene.get_node_or_null("Doors/Door3/LockedVisual") as CanvasItem
	_expect(lv3 == null or lv3.visible == false, "Door3 LockedVisual hidden after F2")

	# After Floor3: all remain unlocked
	if gs:
		gs.zone02_floor3_passed = true
	scene._apply_door_lock_state()
	_expect(bool(scene.get("_door2_locked")) == false, "Door2 stays unlocked after F3")
	_expect(bool(scene.get("_door3_locked")) == false, "Door3 stays unlocked after F3")

	# No mini-game nodes
	_expect(scene.find_child("MiniGame", true, false) == null, "no MiniGame node")
	_expect(scene.find_child("MG1", true, false) == null, "no MG1 node")

	var src := FileAccess.get_file_as_string("res://scripts/zone02/Zone02Exterior.gd")
	_expect(not src.contains("QuizController"), "no QuizController dependency")
	_expect(not src.contains("mini_game") and not src.contains("MiniGame"), "no mini-game dependency")
	_expect(src.contains("Zone02_Floor1.tscn"), "Door1 transition path prepared")
	_expect(src.contains("Zone02_Floor2.tscn"), "Door2 transition path prepared")
	_expect(src.contains("Zone02_Floor3.tscn"), "Door3 transition path prepared")

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_failures += 1
		printerr("FAIL %s" % label)

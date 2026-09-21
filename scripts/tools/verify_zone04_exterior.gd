extends SceneTree
## Zone 04 Exterior — Guide (Volt) + Door1–4 monotonic unlock (no exact layout asserts).
## No Floor 5.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone04 Exterior verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone04_floor1_passed = false
		gs.zone04_floor2_passed = false
		gs.zone04_floor3_passed = false
		gs.zone04_floor4_passed = false
		gs.zone04_complete = false
		gs.zone04_badge_earned = false
		gs.zone04_exterior_spawn_marker = ""

	_expect(ResourceLoader.exists("res://scenes/zone04/Zone04_Exterior.tscn"), "Exterior scene")
	_expect(ResourceLoader.exists("res://scenes/zone04/Zone04_Floor1.tscn"), "Floor1 exists")
	_expect(ResourceLoader.exists("res://scenes/zone04/Zone04_Floor2.tscn"), "Floor2 exists")
	_expect(ResourceLoader.exists("res://scenes/zone04/Zone04_Floor3.tscn"), "Floor3 exists")
	_expect(ResourceLoader.exists("res://scenes/zone04/Zone04_Floor4.tscn"), "Floor4 exists")
	_expect(not ResourceLoader.exists("res://scenes/zone04/Zone04_Floor5.tscn"), "no Floor5")

	var scene: Node = (load("res://scenes/zone04/Zone04_Exterior.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var wing: Sprite2D = scene.get_node_or_null("Background/WingArt") as Sprite2D
	_expect(wing != null and wing.texture != null, "WingArt")
	if wing and wing.texture:
		_expect(String(wing.texture.resource_path).ends_with("substation_entry.png"), "entry art")

	# Exactly one guide NPC
	var guide = scene.get_node_or_null("NPCs/Guide")
	_expect(guide is CharacterBody2D, "Guide NPC")
	var npc_children := 0
	var npcs: Node = scene.get_node_or_null("NPCs")
	if npcs:
		for c in npcs.get_children():
			if c is CharacterBody2D:
				npc_children += 1
	_expect(npc_children == 1, "exactly one guide NPC")
	_expect(guide.get_node_or_null("InteractionArea") is Area2D, "Guide InteractionArea")
	_expect(guide.get_node_or_null("InteractionArea/CollisionShape2D") != null, "Guide IA shape")
	if guide and "display_name" in guide:
		_expect(str(guide.display_name) == "Volt", "Guide is Volt")
	if guide and "sprite_texture" in guide and guide.sprite_texture:
		_expect(String(guide.sprite_texture.resource_path).ends_with("volt.png"), "Volt asset")
	if "can_interact" in guide:
		_expect(bool(guide.can_interact) == false, "Guide interactable off")

	var src := FileAccess.get_file_as_string("res://scripts/zone04/Zone04Exterior.gd")
	_expect(src.contains("GUIDE_LINES"), "guide dialogue exists")
	_expect(src.contains("_on_guide_area_entered"), "automatic proximity interaction")
	_expect(src.contains("_guide_armed"), "re-arm on exit")
	_expect(not src.contains("QuizPanel") and not src.contains("start_quiz") and not src.contains("QuizController"), "guide does not start quiz")
	_expect(src.contains("Zone04_Floor1.tscn"), "Door1 still targets Floor1")
	_expect(src.contains("Zone04_Floor4.tscn"), "Door4 targets Floor4")
	_expect(not src.contains("Floor5"), "Exterior script no Floor5")

	_expect(scene.get_node_or_null("Doors/Door1") is Area2D, "Door1")
	_expect(scene.get_node_or_null("Doors/Door2") is Area2D, "Door2")
	_expect(scene.get_node_or_null("Doors/Door3") is Area2D, "Door3")
	_expect(scene.get_node_or_null("Doors/Door4") is Area2D, "Door4")
	_expect(scene.get_node_or_null("Doors/Door5") == null, "no Door5")
	_expect(scene.get_node_or_null("Floor1ReturnSpawn") != null, "Floor1ReturnSpawn")
	_expect(scene.get_node_or_null("Floor2ReturnSpawn") != null, "Floor2ReturnSpawn")
	_expect(scene.get_node_or_null("Floor3ReturnSpawn") != null, "Floor3ReturnSpawn")

	_expect(bool(scene.get("_door1_available")) == true, "Door1 available")
	_expect(bool(scene.get("_door2_locked")) == true, "Door2 locked initially")
	_expect(bool(scene.get("_door3_locked")) == true, "Door3 locked initially")
	_expect(bool(scene.get("_door4_locked")) == true, "Door4 locked initially")

	if gs:
		gs.zone04_floor1_passed = true
	scene._apply_door_lock_state()
	_expect(bool(scene.get("_door2_locked")) == false, "Door2 unlocked after F1")
	_expect(bool(scene.get("_door3_locked")) == true, "Door3 locked after F1")
	_expect(bool(scene.get("_door4_locked")) == true, "Door4 locked after F1")

	if gs:
		gs.zone04_floor2_passed = true
	scene._apply_door_lock_state()
	_expect(bool(scene.get("_door2_locked")) == false, "Door2 stays unlocked after F2")
	_expect(bool(scene.get("_door3_locked")) == false, "Door3 unlocked after F2")
	_expect(bool(scene.get("_door4_locked")) == true, "Door4 locked after F2")

	if gs:
		gs.zone04_floor3_passed = true
	scene._apply_door_lock_state()
	_expect(bool(scene.get("_door2_locked")) == false, "Door2 stays unlocked after F3")
	_expect(bool(scene.get("_door3_locked")) == false, "Door3 stays unlocked after F3")
	_expect(bool(scene.get("_door4_locked")) == false, "Door4 unlocked after F3")
	var lv4: CanvasItem = scene.get_node_or_null("Doors/Door4/LockedVisual") as CanvasItem
	_expect(lv4 == null or lv4.visible == false, "Door4 LockedVisual hidden after F3")

	var wmsrc := FileAccess.get_file_as_string("res://scripts/world_map/WorldMap.gd")
	_expect(wmsrc.contains("Zone04_Exterior.tscn"), "WorldMap enters Zone04 Exterior")
	_expect(not wmsrc.contains("Zone 04 coming soon"), "WorldMap no longer coming-soon for Z04")

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_failures += 1
		printerr("FAIL %s" % label)

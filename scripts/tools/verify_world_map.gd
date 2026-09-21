extends SceneTree
## Structural check: World Map is click-only (no Player / PlayerSpawn).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== World Map verify (click-only) ===")
	var path := "res://scenes/world_map/WorldMap.tscn"
	if not ResourceLoader.exists(path):
		_fail("missing WorldMap.tscn")
		_finish()
		return

	var src := FileAccess.get_file_as_string("res://scripts/world_map/WorldMap.gd")
	_expect(not src.contains("$Player"), "WorldMap.gd has no $Player")
	_expect(not src.contains("$PlayerSpawn"), "WorldMap.gd has no $PlayerSpawn")
	_expect(not src.contains("player.has_method"), "WorldMap.gd has no player.has_method")
	_expect(not ("\n@onready var player" in src or src.begins_with("@onready var player")), "WorldMap.gd has no player @onready")

	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_expect(scene.get_node_or_null("Background") != null, "Background")
	_expect(scene.get_node_or_null("Player") == null, "no Player node")
	_expect(scene.get_node_or_null("PlayerSpawn") == null, "no PlayerSpawn node")
	_expect(scene.get_node_or_null("Landmarks/Zone01") != null, "Zone01")
	_expect(scene.get_node_or_null("Landmarks/Zone01/ClickArea") != null, "Factory ClickArea")
	_expect(scene.get_node_or_null("Landmarks/Zone01/ClickArea/CollisionShape2D") != null, "Factory ClickArea shape")
	_expect(scene.get_node_or_null("Camera2D") != null, "Camera2D")

	var bg: Sprite2D = scene.get_node("Background") as Sprite2D
	if bg and bg.texture:
		var sz := bg.texture.get_size()
		_expect(int(sz.x) == 1376 and int(sz.y) == 768, "bg 1376x768 (got %sx%s)" % [sz.x, sz.y])
	else:
		_fail("Background texture missing")

	var factory: Sprite2D = scene.get_node_or_null("Landmarks/Zone01/PropArt") as Sprite2D
	_expect(factory != null and factory.texture != null, "factory PropArt texture")

	var z01: Area2D = scene.get_node("Landmarks/Zone01/ClickArea") as Area2D
	_expect(z01 != null and ("is_locked" in z01) and z01.is_locked == false, "Factory unlocked click target")
	_expect(("landmark_id" in z01) and str(z01.landmark_id) == "zone_01", "Factory landmark_id zone_01")

	for locked_path in [
		"Landmarks/Zone02_Locked/ClickArea",
		"Landmarks/Zone03_Locked/ClickArea",
		"Landmarks/Zone04_Locked/ClickArea",
		"Landmarks/Zone05_Locked/ClickArea",
	]:
		var area: Area2D = scene.get_node_or_null(locked_path) as Area2D
		_expect(area != null and area.is_locked == true, "%s locked" % locked_path)

	# Simulate locked click → feedback, no transition
	var prompt: Label = scene.get_node_or_null("UI/PromptLabel") as Label
	var z02: Area2D = scene.get_node("Landmarks/Zone02_Locked/ClickArea") as Area2D
	if scene.has_method("_on_landmark_clicked"):
		scene._on_landmark_clicked(z02)
		await process_frame
		_expect(prompt != null and prompt.visible and prompt.text.contains("Locked"), "locked landmark feedback")
	else:
		_fail("missing _on_landmark_clicked")

	var cam: Camera2D = scene.get_node("Camera2D") as Camera2D
	_expect(is_equal_approx(cam.zoom.x, 0.93), "fixed camera zoom ~0.93")

	scene.queue_free()
	_finish()


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_fail(label)


func _fail(msg: String) -> void:
	_failures += 1
	printerr("FAIL %s" % msg)


func _finish() -> void:
	print("=== failures: %d ===" % _failures)
	quit(_failures)

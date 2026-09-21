extends SceneTree
## Structural check for Zone 01 Floor 1 foundation.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor1 verify ===")
	var path := "res://scenes/zone01/Zone01_Floor1.tscn"
	if not ResourceLoader.exists(path):
		_fail("missing Floor1")
		_finish()
		return

	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_expect(scene.get_node_or_null("Background/Floor1Art") != null, "Floor1Art")
	_expect(scene.get_node_or_null("PlayerSpawn") != null, "PlayerSpawn")
	_expect(scene.get_node_or_null("Player") != null, "Player")
	_expect(scene.get_node_or_null("Collision") != null, "Collision")
	_expect(scene.get_node_or_null("NPCs/Manager") != null, "Manager")
	_expect(scene.get_node_or_null("Interactions/MG1_Handoff") != null, "MG1_Handoff")
	_expect(scene.get_node_or_null("Interactions/Floor2Entrance") != null, "Floor2Entrance")
	_expect(scene.get_node_or_null("Interactions/ExteriorExit") != null, "ExteriorExit")
	_expect(ResourceLoader.exists("res://scenes/zone01/MiniGame01_Brake_Stub.tscn"), "MG1 stub scene")

	var art: Sprite2D = scene.get_node("Background/Floor1Art") as Sprite2D
	_expect(
		art.texture != null and int(art.texture.get_size().x) == 1296 and int(art.texture.get_size().y) == 1080,
		"floor art 1296x1080"
	)

	var spawn: Marker2D = scene.get_node("PlayerSpawn") as Marker2D
	var player: Node2D = scene.get_node("Player") as Node2D
	_expect(player.global_position.distance_to(spawn.global_position) < 2.0, "player at PlayerSpawn")

	var workers: Node = scene.get_node("NPCs/Workers")
	var wcount := 0
	for c in workers.get_children():
		if str(c.name).begins_with("Worker_"):
			wcount += 1
	_expect(wcount >= 2, "ambient workers >= 2 (got %d)" % wcount)

	# Collision children exist; grass/floor not one giant room block covering all
	var col: Node = scene.get_node("Collision")
	_expect(col.get_child_count() >= 5, "multiple collision pieces")

	# Manager position not rewritten (scene default)
	var mgr: Node2D = scene.get_node("NPCs/Manager") as Node2D
	_expect(mgr.position.distance_to(Vector2(441, 280)) < 0.5, "manager scene-authored pos")

	# No quiz / physics scripts on this scene
	var script_path := str(scene.get_script().resource_path) if scene.get_script() else ""
	_expect(script_path.ends_with("Zone01Floor1.gd"), "uses Zone01Floor1.gd")

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

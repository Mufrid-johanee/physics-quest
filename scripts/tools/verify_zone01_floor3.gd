extends SceneTree
## Structural check for Zone 01 Floor 3.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor3 verify ===")
	var path := "res://scenes/zone01/Zone01_Floor3.tscn"
	if not ResourceLoader.exists(path):
		_fail("missing Floor3")
		_finish()
		return

	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_expect(scene.get_node_or_null("Background/Floor3Art") != null, "Floor3Art")
	_expect(scene.get_node_or_null("PlayerSpawn") != null, "PlayerSpawn")
	_expect(scene.get_node_or_null("Player") != null, "Player")
	_expect(scene.get_node_or_null("Collision") != null, "Collision")
	_expect(scene.get_node_or_null("NPCs/Manager") != null, "Manager")
	_expect(scene.get_node_or_null("Interactions/Floor2Entrance") != null, "Floor2Entrance")
	_expect(scene.get_node_or_null("Interactions/Floor4Entrance") != null, "Floor4Entrance")

	var art: Sprite2D = scene.get_node("Background/Floor3Art") as Sprite2D
	_expect(
		art.texture != null and int(art.texture.get_size().x) == 1296 and int(art.texture.get_size().y) == 1080,
		"floor3 art 1296x1080"
	)

	var spawn: Marker2D = scene.get_node("PlayerSpawn") as Marker2D
	var player: Node2D = scene.get_node("Player") as Node2D
	_expect(player.global_position.distance_to(spawn.global_position) < 2.0, "player at PlayerSpawn")

	var mgr: Node2D = scene.get_node("NPCs/Manager") as Node2D
	_expect(mgr.position.distance_to(Vector2(420, 280)) < 0.5, "manager scene-authored")

	var workers: Node = scene.get_node_or_null("NPCs/Workers")
	var wcount := 0
	if workers:
		for c in workers.get_children():
			if str(c.name).begins_with("Worker_"):
				wcount += 1
	_expect(wcount == 2, "ambient workers == 2 (got %d)" % wcount)
	_expect(scene.get_node_or_null("NPCs/LabAssistant") == null, "no LabAssistant (Floor2-only cast)")
	_expect(scene.get_node_or_null("NPCs/Director") == null, "no Director (Floor4)")

	_expect(scene.get_node("Collision").get_child_count() >= 6, "multiple collision pieces")
	var script_path := str(scene.get_script().resource_path) if scene.get_script() else ""
	_expect(script_path.ends_with("Zone01Floor3.gd"), "uses Zone01Floor3.gd")

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

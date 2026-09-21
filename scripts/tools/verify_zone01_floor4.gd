extends SceneTree
## Structural check for Zone 01 Floor 4.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor4 verify ===")
	var path := "res://scenes/zone01/Zone01_Floor4.tscn"
	if not ResourceLoader.exists(path):
		_fail("missing Floor4")
		_finish()
		return

	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_expect(scene.get_node_or_null("Background/Floor4Art") != null, "Floor4Art")
	_expect(scene.get_node_or_null("PlayerSpawn") != null, "PlayerSpawn")
	_expect(scene.get_node_or_null("Player") != null, "Player")
	_expect(scene.get_node_or_null("Collision") != null, "Collision")
	_expect(scene.get_node_or_null("NPCs/Director") != null, "Director")
	_expect(scene.get_node_or_null("Interactions/Floor3Entrance") != null, "Floor3Entrance")
	_expect(scene.get_node_or_null("Interactions/MiniGameHandoff") != null, "MiniGameHandoff")

	var art: Sprite2D = scene.get_node("Background/Floor4Art") as Sprite2D
	_expect(
		art.texture != null and int(art.texture.get_size().x) == 1296 and int(art.texture.get_size().y) == 1080,
		"floor4 art 1296x1080"
	)

	var npcs: Node = scene.get_node("NPCs")
	var names: Array = []
	for c in npcs.get_children():
		names.append(str(c.name))
	_expect(names.size() == 1 and names[0] == "Director", "exactly Director only (got %s)" % str(names))

	var spawn: Marker2D = scene.get_node("PlayerSpawn") as Marker2D
	var player: Node2D = scene.get_node("Player") as Node2D
	_expect(player.global_position.distance_to(spawn.global_position) < 2.0, "player at PlayerSpawn")

	var director: Node2D = scene.get_node("NPCs/Director") as Node2D
	_expect(director.position.distance_to(Vector2(680, 200)) < 0.5, "director scene-authored")

	_expect(scene.get_node("Collision").get_child_count() >= 6, "multiple collision pieces")
	var script_path := str(scene.get_script().resource_path) if scene.get_script() else ""
	_expect(script_path.ends_with("Zone01Floor4.gd"), "uses Zone01Floor4.gd")
	_expect(ResourceLoader.exists("res://scenes/zone01/MiniGame01_Brake_Stub.tscn"), "MG stub exists")

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

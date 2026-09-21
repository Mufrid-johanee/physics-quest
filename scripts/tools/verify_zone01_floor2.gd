extends SceneTree
## Structural check: Floor 2 locked cast + layout.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor2 verify ===")
	var path := "res://scenes/zone01/Zone01_Floor2.tscn"
	if not ResourceLoader.exists(path):
		_fail("missing Floor2")
		_finish()
		return

	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_expect(scene.get_node_or_null("Background/Floor2Art") != null, "Floor2Art")
	_expect(scene.get_node_or_null("PlayerSpawn") != null, "PlayerSpawn")
	_expect(scene.get_node_or_null("Player") != null, "Player")
	_expect(scene.get_node_or_null("Collision") != null, "Collision")
	_expect(scene.get_node_or_null("NPCs/Manager") != null, "Manager")
	_expect(scene.get_node_or_null("NPCs/LabAssistant") != null, "LabAssistant")
	_expect(scene.get_node_or_null("Interactions/Floor1Entrance") != null, "Floor1Entrance")
	_expect(scene.get_node_or_null("Interactions/Floor3Entrance") != null, "Floor3Entrance")

	var art: Sprite2D = scene.get_node("Background/Floor2Art") as Sprite2D
	_expect(
		art.texture != null and int(art.texture.get_size().x) == 1296 and int(art.texture.get_size().y) == 1080,
		"floor2 art 1296x1080"
	)

	# Exact cast: only Manager + LabAssistant under NPCs (no Workers group extras)
	var npcs: Node = scene.get_node("NPCs")
	var npc_children := []
	for c in npcs.get_children():
		npc_children.append(str(c.name))
	_expect(npc_children.has("Manager") and npc_children.has("LabAssistant"), "cast names present")
	_expect(npc_children.size() == 2, "exactly 2 NPC nodes (got %d: %s)" % [npc_children.size(), str(npc_children)])

	var spawn: Marker2D = scene.get_node("PlayerSpawn") as Marker2D
	var player: Node2D = scene.get_node("Player") as Node2D
	_expect(player.global_position.distance_to(spawn.global_position) < 2.0, "player at PlayerSpawn")

	var mgr: Node2D = scene.get_node("NPCs/Manager") as Node2D
	var lab: Node2D = scene.get_node("NPCs/LabAssistant") as Node2D
	_expect(mgr.position.distance_to(Vector2(441, 260)) < 0.5, "manager scene pos unchanged")
	_expect(lab.position.distance_to(Vector2(620, 560)) < 0.5, "lab scene pos unchanged")

	_expect(scene.get_node("Collision").get_child_count() >= 6, "multiple collision pieces")

	var script_path := str(scene.get_script().resource_path) if scene.get_script() else ""
	_expect(script_path.ends_with("Zone01Floor2.gd"), "uses Zone01Floor2.gd")

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

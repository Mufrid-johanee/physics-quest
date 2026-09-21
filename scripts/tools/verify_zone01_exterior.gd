extends SceneTree
## Structural check for Zone 01 Exterior foundation.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Exterior verify ===")
	var path := "res://scenes/zone01/Zone01_Exterior.tscn"
	if not ResourceLoader.exists(path):
		_fail("missing Zone01_Exterior.tscn")
		_finish()
		return

	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_expect(scene.get_node_or_null("Background/YardGrass") != null, "YardGrass")
	_expect(scene.get_node_or_null("Background/FactoryExterior") != null, "FactoryExterior")
	_expect(scene.get_node_or_null("Background/EntranceRoad") != null, "EntranceRoad")
	_expect(scene.get_node_or_null("Player") != null, "Player")
	_expect(scene.get_node_or_null("PlayerSpawn") != null, "PlayerSpawn")
	_expect(scene.get_node_or_null("NPCs/Guard") != null, "Guard")
	_expect(scene.get_node_or_null("Gate/LockedVisual") != null, "LockedVisual")
	_expect(scene.get_node_or_null("Gate/OpenVisual") != null, "OpenVisual")
	_expect(scene.get_node_or_null("Gate/Barrier/CollisionShape2D") != null, "Gate barrier")
	_expect(scene.get_node_or_null("InteractionPoints/Floor1Entrance") != null, "Floor1Entrance")
	_expect(scene.get_node_or_null("Collision") != null, "Collision")

	var grass: Sprite2D = scene.get_node("Background/YardGrass") as Sprite2D
	_expect(grass.texture != null and int(grass.texture.get_size().x) == 1376, "grass 1376 wide")

	var locked: Sprite2D = scene.get_node("Gate/LockedVisual") as Sprite2D
	var opened: Sprite2D = scene.get_node("Gate/OpenVisual") as Sprite2D
	var barrier: CollisionShape2D = scene.get_node("Gate/Barrier/CollisionShape2D") as CollisionShape2D
	_expect(locked.visible and not opened.visible, "gate starts locked visually")
	_expect(not barrier.disabled, "gate barrier active when locked")

	var workers: Node = scene.get_node("NPCs/Workers")
	var count := 0
	for child in workers.get_children():
		if str(child.name).begins_with("Worker_"):
			count += 1
	_expect(count >= 6, "workers >= 6 (got %d)" % count)
	print("OK worker count=%d" % count)

	# Conversation-facing pairs (defaults): 01/02, 03/04, 07/08
	var w01 = workers.get_node("Worker_01")
	var w02 = workers.get_node("Worker_02")
	_expect(w01.face_left == false and w02.face_left == true, "conversation group A facing")
	var w03 = workers.get_node("Worker_03")
	var w04 = workers.get_node("Worker_04")
	_expect(w03.face_left == false and w04.face_left == true, "conversation group B facing")

	var spawn: Marker2D = scene.get_node("PlayerSpawn") as Marker2D
	var player: Node2D = scene.get_node("Player") as Node2D
	_expect(player.global_position.distance_to(spawn.global_position) < 2.0, "player at PlayerSpawn")

	# Simulate grant
	if scene.has_method("_grant_gate_access"):
		await scene._grant_gate_access()
		await process_frame
		_expect(not locked.visible and opened.visible, "gate open visuals after grant")
		_expect(barrier.disabled, "gate barrier disabled after grant")
		var gs := root.get_node_or_null("/root/GameState")
		_expect(gs != null and gs.zone01_guard_granted, "GameState.zone01_guard_granted")
	else:
		_fail("missing _grant_gate_access")

	# Ensure no worker positions rewritten by grant
	_expect(
		workers.get_node("Worker_01").position.distance_to(Vector2(280, 380)) < 0.5,
		"worker positions unchanged after grant"
	)

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

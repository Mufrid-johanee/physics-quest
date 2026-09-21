extends Node2D
## Foundation verification scene. Not production gameplay.

@onready var status_label: Label = $UI/StatusLabel
@onready var player: CharacterBody2D = $Player
@onready var npc: CharacterBody2D = $DemoNPC


func _ready() -> void:
	status_label.text = (
		"PHYSICS QUEST — Foundation Boot\n"
		+ "WASD/Arrows move | E/F interact with NPC | Walk into green zone to test SceneTransition\n"
		+ "Zone01 unlocked=%s" % GameState.is_zone_unlocked(GameState.ZONE_01)
	)
	if npc and npc.has_signal("interaction_requested"):
		npc.interaction_requested.connect(_on_npc_interact)


func _on_npc_interact(who: Node) -> void:
	var lines: PackedStringArray = []
	if who.has_method("get_dialogue_lines"):
		lines = who.get_dialogue_lines()
	var msg := "NPC interaction OK"
	if lines.size() > 0:
		msg = lines[0]
	status_label.text = "Interact: %s\n(Foundation test — full dialogue UI later)" % msg

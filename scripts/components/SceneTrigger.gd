extends Area2D
## Scene change trigger. Target path is an export — place/size the Area in the editor.

@export_file("*.tscn") var target_scene: String = ""
@export var enabled: bool = true
@export var one_shot: bool = true
@export var require_player_group: bool = true
@export var player_group: String = "player"

var _fired: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not enabled:
		return
	if _fired and one_shot:
		return
	if require_player_group and not body.is_in_group(player_group):
		return
	if target_scene.is_empty():
		push_warning("SceneTrigger '%s': empty target_scene" % name)
		return
	_fired = true
	SceneTransition.change_to(target_scene)

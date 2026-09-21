extends CharacterBody2D
## Reusable player: move, face, collide, scripted move, seated pose.
## Visuals are static directional Sprite2D textures (no walk-frame animation).
## Scene transforms (position/scale) are authored in the .tscn — this script does not overwrite them.

enum Facing { DOWN, UP, LEFT, RIGHT }

@export var move_speed: float = 180.0
@export var sprite_scale: float = 0.35
@export var apply_sprite_scale_on_ready: bool = true
## When true, WASD is ignored (opening sequences, cutscenes).
@export var scripted_control: bool = false
@export var start_seated: bool = false
@export var seated_sprite_scale: float = 0.13
@export var apply_seated_scale_on_ready: bool = true

@export var tex_down: Texture2D
@export var tex_up: Texture2D
@export var tex_left: Texture2D
@export var tex_right: Texture2D

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var seated_sprite: Sprite2D = get_node_or_null("SeatedSprite") as Sprite2D

var facing: Facing = Facing.DOWN
var is_seated: bool = false
var _script_tween: Tween


func _ready() -> void:
	collision_layer = 1
	# Layer 2 = world/walls; layer 4 = NPC/character bodies (see NPCController).
	collision_mask = 2 | 4
	if sprite and apply_sprite_scale_on_ready and sprite.scale == Vector2.ONE:
		sprite.scale = Vector2(sprite_scale, sprite_scale)
	if seated_sprite and apply_seated_scale_on_ready and seated_sprite.scale == Vector2.ONE:
		seated_sprite.scale = Vector2(seated_sprite_scale, seated_sprite_scale)
	if start_seated:
		set_seated(true)
	else:
		set_seated(false)
		_apply_facing_sprite()


func _physics_process(_delta: float) -> void:
	if scripted_control or is_seated:
		return
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vec * move_speed
	move_and_slide()
	if input_vec.length() > 0.01:
		_update_facing(input_vec)
		_apply_facing_sprite()
	# Idle: keep last facing sprite (no animation swap).


func set_scripted_control(enabled: bool) -> void:
	scripted_control = enabled
	if enabled:
		velocity = Vector2.ZERO


func set_seated(seated: bool) -> void:
	is_seated = seated
	if seated_sprite:
		seated_sprite.visible = seated
	if sprite:
		sprite.visible = not seated
	if collision_shape:
		collision_shape.disabled = seated
	if seated:
		set_scripted_control(true)
		velocity = Vector2.ZERO
	else:
		_apply_facing_sprite()


func set_facing_direction(new_facing: Facing) -> void:
	facing = new_facing
	if not is_seated:
		_apply_facing_sprite()


func face_toward(global_target: Vector2) -> void:
	var diff := global_target - global_position
	if diff.length() < 0.5:
		return
	_update_facing(diff.normalized())
	if not is_seated:
		_apply_facing_sprite()


## Moves along points without player input. Does not rewrite Marker2D positions.
func move_along_path(
	points: Array[Vector2],
	speed: float = -1.0,
	release_control: bool = true
) -> void:
	if points.is_empty():
		return
	var use_speed := move_speed if speed <= 0.0 else speed
	set_scripted_control(true)
	if _script_tween and _script_tween.is_running():
		_script_tween.kill()
	for point in points:
		var diff := point - global_position
		if diff.length() > 1.0:
			_update_facing(diff.normalized())
			_apply_facing_sprite()
		var duration := diff.length() / maxf(use_speed, 1.0)
		_script_tween = create_tween()
		_script_tween.tween_property(self, "global_position", point, duration)
		await _script_tween.finished
	_apply_facing_sprite()
	if release_control:
		set_scripted_control(false)


func _update_facing(dir: Vector2) -> void:
	if absf(dir.x) > absf(dir.y):
		facing = Facing.RIGHT if dir.x > 0.0 else Facing.LEFT
	else:
		facing = Facing.DOWN if dir.y > 0.0 else Facing.UP


func _apply_facing_sprite() -> void:
	if is_seated or sprite == null:
		return
	match facing:
		Facing.UP:
			if tex_up:
				sprite.texture = tex_up
		Facing.LEFT:
			if tex_left:
				sprite.texture = tex_left
		Facing.RIGHT:
			if tex_right:
				sprite.texture = tex_right
		_:
			if tex_down:
				sprite.texture = tex_down
	sprite.flip_h = false

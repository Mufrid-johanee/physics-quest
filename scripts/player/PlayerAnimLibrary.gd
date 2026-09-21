class_name PlayerAnimLibrary
extends RefCounted
## Builds SpriteFrames from the supplied walk sheet.
## Sheet: asset/sprites/animation/player animation.png (1407x768)
## Layout (3x3): row0 DOWN, row1 UP, row2 RIGHT. Left = flip of right at runtime.

const SHEET_PATH := "res://asset/sprites/animation/player animation.png"
const COLS := 3
const ROWS := 3


static func build_frames() -> SpriteFrames:
	var tex := load(SHEET_PATH) as Texture2D
	if tex == null:
		push_error("PlayerAnimLibrary: missing sheet at %s" % SHEET_PATH)
		return SpriteFrames.new()

	var frame_w := int(tex.get_width() / float(COLS))
	var frame_h := int(tex.get_height() / float(ROWS))
	var frames := SpriteFrames.new()

	_add_dir(frames, tex, "down", 0, frame_w, frame_h)
	_add_dir(frames, tex, "up", 1, frame_w, frame_h)
	_add_dir(frames, tex, "right", 2, frame_w, frame_h)
	# Left clips reuse right atlases; PlayerController flips the sprite.
	_add_dir(frames, tex, "left", 2, frame_w, frame_h)
	return frames


static func _add_dir(
	frames: SpriteFrames,
	tex: Texture2D,
	dir_name: String,
	row: int,
	frame_w: int,
	frame_h: int
) -> void:
	var idle_name := "idle_%s" % dir_name
	var walk_name := "walk_%s" % dir_name
	if not frames.has_animation(idle_name):
		frames.add_animation(idle_name)
	if not frames.has_animation(walk_name):
		frames.add_animation(walk_name)
	frames.set_animation_speed(idle_name, 1.0)
	frames.set_animation_speed(walk_name, 6.0)
	frames.set_animation_loop(idle_name, true)
	frames.set_animation_loop(walk_name, true)

	for col in COLS:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
		if col == 0:
			frames.add_frame(idle_name, atlas)
		frames.add_frame(walk_name, atlas)

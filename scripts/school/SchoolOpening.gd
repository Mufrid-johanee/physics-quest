extends Node2D
## School opening cutscene. Scene tree owns all transforms — this script never repositions
## Teacher, AmbientStudents, Collision shapes, or OpeningSequence markers.

enum SequenceState {
	PLAYER_SEATED,
	TEACHER_INTERACTION,
	PLAYER_STANDS,
	PLAYER_WALKS_TO_DOOR,
	PLAYER_EXITS,
	WORLD_MAP_TRANSITION,
}

const WORLD_MAP_PATH := "res://scenes/world_map/WorldMap.tscn"

## Documented dialogue from PHYSICS_QUEST_MASTER.md §1.2
## Additive Supervisor context for factory floors — see Docs/AMBIENT_CHARACTERS.md
const TEACHER_LINE := "Welcome to Physics Quest! You need to secure at least 80% marks in your assignments to pass."
const TEACHER_LINE_SUPERVISOR := "Each floor of the factory has a Supervisor. They may ask you different questions and guide you as you explore."
const STUDENT_LINE := "Understood, Sir! I will do my best."

@export var walk_speed: float = 140.0
@export var auto_start: bool = true
@export var start_delay_sec: float = 0.4

@onready var main_player: CharacterBody2D = $MainPlayer
@onready var teacher: Node2D = $Teacher
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var opening: Node2D = $OpeningSequence
@onready var stand_point: Marker2D = $OpeningSequence/StandPoint
@onready var walk_point_01: Marker2D = $OpeningSequence/WalkPoint_01
@onready var walk_point_02: Marker2D = $OpeningSequence/WalkPoint_02
@onready var door_point: Marker2D = $OpeningSequence/DoorPoint
@onready var exit_point: Marker2D = $OpeningSequence/ExitPoint

var _state: SequenceState = SequenceState.PLAYER_SEATED
var _running: bool = false


func _ready() -> void:
	if main_player.has_method("set_seated"):
		main_player.set_seated(true)
	if main_player.has_method("set_scripted_control"):
		main_player.set_scripted_control(true)
	if auto_start:
		await get_tree().create_timer(start_delay_sec).timeout
		start_opening_sequence()


func start_opening_sequence() -> void:
	if _running:
		return
	_running = true
	await _run_sequence()


func _run_sequence() -> void:
	_set_state(SequenceState.PLAYER_SEATED)

	_set_state(SequenceState.TEACHER_INTERACTION)
	if main_player.has_method("face_toward"):
		main_player.face_toward(teacher.global_position)
	await _show_line("Teacher", TEACHER_LINE)
	await _show_line("Teacher", TEACHER_LINE_SUPERVISOR)
	await _show_line("Student", STUDENT_LINE)
	dialogue.hide_dialogue()

	_set_state(SequenceState.PLAYER_STANDS)
	if main_player.has_method("set_seated"):
		main_player.set_seated(false)
	if main_player.has_method("set_scripted_control"):
		main_player.set_scripted_control(true)
	if main_player.has_method("face_toward"):
		main_player.face_toward(teacher.global_position)
	await get_tree().create_timer(0.35).timeout

	_set_state(SequenceState.PLAYER_WALKS_TO_DOOR)
	var path: Array[Vector2] = [
		stand_point.global_position,
		walk_point_01.global_position,
		walk_point_02.global_position,
		door_point.global_position,
	]
	if main_player.has_method("move_along_path"):
		await main_player.move_along_path(path, walk_speed, false)

	_set_state(SequenceState.PLAYER_EXITS)
	if main_player.has_method("move_along_path"):
		await main_player.move_along_path(
			[exit_point.global_position] as Array[Vector2],
			walk_speed,
			false
		)

	_set_state(SequenceState.WORLD_MAP_TRANSITION)
	SceneTransition.change_to(WORLD_MAP_PATH)


func _show_line(speaker: String, text: String) -> void:
	dialogue.show_line(speaker, text)
	await dialogue.line_finished


func _set_state(next: SequenceState) -> void:
	_state = next


func get_sequence_state() -> SequenceState:
	return _state

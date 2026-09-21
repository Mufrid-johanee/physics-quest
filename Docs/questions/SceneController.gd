extends Node

@onready var dialogue = $DialogueSystem/DialogueController
@onready var teacher  = $Characters/Teacher
@onready var player_a = $Characters/PlayerA
@onready var paper    = $Props/AssignmentPaper
@onready var music    = $AudioPlayers/MusicPlayer
@onready var ambient  = $AudioPlayers/AmbientPlayer
@onready var fade_rect = $CanvasLayer/FadeRect

var sfx_bell = preload("res://asset/music/sfx_school_bell.ogg")
var sfx_chair = preload("res://asset/music/sfx_chair_scrape.ogg")
var sfx_paper = preload("res://asset/music/sfx_paper_rustle.ogg")
var sfx_steps = preload("res://asset/music/sfx_footsteps_wood.ogg")
var music_sting = preload("res://asset/music/music_opening_sting.ogg")
var amb_track = preload("res://asset/music/amb_classroom.ogg")

func play_sfx(stream: AudioStream, volume: float = 0.0):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _ready() -> void:
	if paper: paper.visible = false
	if ambient: 
		ambient.stream = amb_track
		ambient.volume_db = linear_to_db(0.25)
		ambient.play()
	if music:
		music.stream = music_sting
		music.volume_db = linear_to_db(0.7)
	await get_tree().create_timer(1.5).timeout  # Fade in duration
	play_sfx(sfx_bell, linear_to_db(0.4))
	run_cutscene()

func run_cutscene() -> void:
	await get_tree().create_timer(2.0).timeout  # Opening pause

	# Beat 2
	play_sfx(sfx_chair, linear_to_db(0.3))
	if dialogue: await dialogue.show_line("Physics Teacher", "A... before you leave.")
	
	# Beat 3
	if teacher: teacher.play("walk_to_desk")
	play_sfx(sfx_steps, linear_to_db(0.4))
	await get_tree().create_timer(0.8).timeout
	if dialogue: await dialogue.show_line("Physics Teacher", "This year, you have studied the laws that govern our physical world.")

	# Beat 4
	if teacher: teacher.play("hold_paper_out")
	if paper: paper.visible = true
	play_sfx(sfx_paper, linear_to_db(0.5))
	if dialogue:
		await dialogue.show_line("Physics Teacher", "But knowing a law and applying it are two very different things.")
		await dialogue.show_line("Physics Teacher", "This is your final assignment.")

	# Beat 5 & 6
	if dialogue:
		await dialogue.show_line("Physics Teacher", "You will visit five field experts across the country.")
		await dialogue.show_line("Physics Teacher", "Each one will assess whether you truly understand physics —")
		await dialogue.show_line("Physics Teacher", "not on paper... but in the real world.")

	# Beat 7
	if dialogue:
		await dialogue.show_line("Physics Teacher", "Start with the Rajshahi Industrial Factory.")
		await dialogue.show_line("Physics Teacher", "The head of mechanics there is expecting you.")
	if player_a: player_a.play("receive_paper")
	play_sfx(sfx_paper, linear_to_db(0.5))

	# Beat 8
	if dialogue: await dialogue.show_line("A", "I won't let you down, sir.")
	if player_a: player_a.play("look_up")
	if teacher: teacher.play("nod")
	await get_tree().create_timer(0.6).timeout

	# Beat 9
	if dialogue: await dialogue.show_line("Physics Teacher", "I know you won't.")
	if teacher: teacher.play("turn_away")
	if player_a: player_a.play("look_down")
	if ambient: ambient.stop()
	if music: music.play()
	await get_tree().create_timer(3.0).timeout
	
	# Fade to black → World Map
	if fade_rect and fade_rect.has_method("fade_to_black"):
		fade_rect.fade_to_black()
	await get_tree().create_timer(2.0).timeout
	
	# SceneManager.go_to("WorldMap")
	print("Transition to World Map")

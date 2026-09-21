extends Node
## DRAFT / UNUSED — live runtime controller is res://scripts/quiz/QuizController.gd
## class_name removed to avoid conflicting with the active QuizController.

signal quiz_passed(floor)
signal quiz_failed(floor)

var question_bank: Array = []
var session_questions: Array = []
var current_index: int = 0
var score: int = 0
var current_floor: int = 0

var current_question: Dictionary = {}
var seen_question_ids: Array = []

func load_floor_questions(floor_number: int) -> void:
	current_floor = floor_number
	var file_path = "res://data/zone01_floor%d_questions.json" % floor_number
	
	if not FileAccess.file_exists(file_path):
		push_error("Question bank file not found: " + file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data == null:
		push_error("Failed to parse JSON file: " + file_path)
		return
		
	question_bank = data.get("questions", [])
	var questions_needed = data.get("questions_to_load", 15)
	
	# If the file defines specific counts for mixed questions (Floors 3/4)
	if data.has("mcq_count") and data.has("one_word_count"):
		_load_mixed_floor_questions(data["mcq_count"], data["one_word_count"], questions_needed)
	else:
		# Standard load
		var unseen = question_bank.filter(
			func(q): return not (q["id"] in seen_question_ids)
		)
		
		# If unseen pool is too small, reset seen list
		if unseen.size() < questions_needed:
			seen_question_ids.clear()
			unseen = question_bank.duplicate()
			
		unseen.shuffle()
		session_questions = unseen.slice(0, questions_needed)
	
	current_index = 0
	score = 0
	
	if session_questions.size() > 0:
		_load_question(session_questions[current_index])

func _load_mixed_floor_questions(mcq_count: int, one_word_count: int, total_needed: int) -> void:
	# Filter unseen questions first
	var unseen = question_bank.filter(
		func(q): return not (q["id"] in seen_question_ids)
	)
	
	# Check if we have enough unseen, if not reset
	if unseen.size() < total_needed:
		seen_question_ids.clear()
		unseen = question_bank.duplicate()

	var mcq_pool = unseen.filter(func(q): return q.get("format") == "mcq")
	var ow_pool  = unseen.filter(func(q): return q.get("format") == "one_word")
	
	# If resetting was needed but we still don't have enough of a type, fallback
	if mcq_pool.size() < mcq_count or ow_pool.size() < one_word_count:
		seen_question_ids.clear()
		mcq_pool = question_bank.filter(func(q): return q.get("format") == "mcq")
		ow_pool = question_bank.filter(func(q): return q.get("format") == "one_word")
		
	mcq_pool.shuffle()
	ow_pool.shuffle()
	
	session_questions  = mcq_pool.slice(0, mcq_count)
	session_questions += ow_pool.slice(0, one_word_count)
	
	# Shuffle the combined list so one-word answers aren't always last
	session_questions.shuffle()

func _load_question(question: Dictionary) -> void:
	current_question = question
	
	# TODO: Connect to actual UI nodes when they are created
	# Example logic from design document:
	# $QuestionLabel.text = question["question"]
	# 
	# if question["format"] == "mcq":
	#     var options = question["options"]
	#     for i in range(options.size()):
	#         $OptionsContainer.get_child(i).text = options[i]
	# elif question["format"] == "one_word":
	#     $AnswerInput.text = ""

func _on_option_button_pressed(selected_text: String) -> void:
	check_answer(selected_text)

func _on_submit_button_pressed(raw_input: String) -> void:
	var cleaned = raw_input.strip_edges().to_lower()
	check_one_word_answer(cleaned)

func check_answer(player_answer: String) -> void:
	var correct = current_question.get("answer", "")
	if current_question.has("correct_answer"):
		correct = current_question["correct_answer"]
		
	if player_answer == correct:
		show_feedback(true, current_question.get("explanation", ""))
		score += 1
	else:
		show_feedback(false, current_question.get("explanation", ""))

func check_one_word_answer(player_answer: String) -> void:
	var accepted = current_question.get("accepted_answers", [])
	
	if player_answer in accepted:
		show_feedback(true, current_question.get("explanation", ""))
		score += 1
	else:
		show_feedback(false, current_question.get("explanation", ""))

func show_feedback(is_correct: bool, explanation: String) -> void:
	# TODO: Implement UI feedback display
	pass
	
func _on_feedback_dismissed() -> void:
	advance_to_next_question()

func advance_to_next_question() -> void:
	current_index += 1
	
	if current_index >= session_questions.size():
		end_quiz()
	else:
		_load_question(session_questions[current_index])

func end_quiz() -> void:
	mark_questions_as_seen()
	
	# Note: GDD says 80% for Floors 1-3 (12/15) and 80% for Floor 4 (16/20).
	var pass_threshold = session_questions.size() * 0.80
	
	if score >= pass_threshold:
		emit_signal("quiz_passed", current_floor)
	else:
		emit_signal("quiz_failed", current_floor)

func mark_questions_as_seen() -> void:
	for q in session_questions:
		if q.has("id"):
			seen_question_ids.append(q["id"])

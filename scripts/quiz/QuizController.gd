extends Node
## Zone 01 floor quiz controller. Selects exactly 10 questions from a floor bank.
## Supports MCQ and one_word formats. Demo mode: MCQ first option / one_word any non-empty.
## Does not mutate question JSON or reorder options.

class_name QuizController

signal quiz_passed(score: int, total: int, percent: float)
signal quiz_failed(score: int, total: int, percent: float)
signal question_changed(index: int, total: int, question: Dictionary)
signal answer_resolved(correct: bool, explanation: String)

const FLOOR1_BANK_PATH := "res://data/zone01_floor1_questions.json"
const FLOOR2_BANK_PATH := "res://data/zone01_floor2_questions.json"
const FLOOR3_BANK_PATH := "res://data/zone01_floor3_questions.json"
const FLOOR4_BANK_PATH := "res://data/zone01_floor4_questions.json"
const ZONE02_FLOOR1_BANK_PATH := "res://data/zone02_floor1_questions.json"
const ZONE02_FLOOR2_BANK_PATH := "res://data/zone02_floor2_questions.json"
const ZONE02_FLOOR3_BANK_PATH := "res://data/zone02_floor3_questions.json"
const ZONE02_FLOOR4_BANK_PATH := "res://data/zone02_floor4_questions.json"
const ZONE03_FLOOR1_BANK_PATH := "res://data/zone03_floor1_questions.json"
const ZONE03_FLOOR2_BANK_PATH := "res://data/zone03_floor2_questions.json"
const ZONE03_FLOOR3_BANK_PATH := "res://data/zone03_floor3_questions.json"
const ZONE03_FLOOR4_BANK_PATH := "res://data/zone03_floor4_questions.json"
const ZONE04_FLOOR1_BANK_PATH := "res://data/zone04_floor1_questions.json"
const ZONE04_FLOOR2_BANK_PATH := "res://data/zone04_floor2_questions.json"
const ZONE04_FLOOR3_BANK_PATH := "res://data/zone04_floor3_questions.json"
const ZONE04_FLOOR4_BANK_PATH := "res://data/zone04_floor4_questions.json"
const QUESTIONS_PER_QUIZ := 10
const PASS_THRESHOLD := 0.80

## When true:
## - MCQ: first displayed option is treated as correct (demo/testing only).
## - one_word: any non-empty typed answer is treated as correct (demo/testing only).
## Does not modify JSON or reorder options permanently.
@export var demo_first_option_is_correct: bool = true

var question_bank: Array = []
var session_questions: Array = []
var current_index: int = 0
var score: int = 0
var current_floor: int = 1
var current_question: Dictionary = {}
var _awaiting_advance: bool = false
var _quiz_active: bool = false


func load_floor1_bank() -> bool:
	return _load_bank(FLOOR1_BANK_PATH, 1)


func load_floor2_bank() -> bool:
	return _load_bank(FLOOR2_BANK_PATH, 2)


func load_floor3_bank() -> bool:
	return _load_bank(FLOOR3_BANK_PATH, 3)


func load_floor4_bank() -> bool:
	return _load_bank(FLOOR4_BANK_PATH, 4)


func load_zone02_floor1_bank() -> bool:
	return _load_bank(ZONE02_FLOOR1_BANK_PATH, 1)


func load_zone02_floor2_bank() -> bool:
	return _load_bank(ZONE02_FLOOR2_BANK_PATH, 2)


func load_zone02_floor3_bank() -> bool:
	return _load_bank(ZONE02_FLOOR3_BANK_PATH, 3)


func load_zone02_floor4_bank() -> bool:
	return _load_bank(ZONE02_FLOOR4_BANK_PATH, 4)


func load_zone03_floor1_bank() -> bool:
	return _load_bank(ZONE03_FLOOR1_BANK_PATH, 1)


func load_zone03_floor2_bank() -> bool:
	return _load_bank(ZONE03_FLOOR2_BANK_PATH, 2)


func load_zone03_floor3_bank() -> bool:
	return _load_bank(ZONE03_FLOOR3_BANK_PATH, 3)


func load_zone03_floor4_bank() -> bool:
	return _load_bank(ZONE03_FLOOR4_BANK_PATH, 4)


func load_zone04_floor1_bank() -> bool:
	return _load_bank(ZONE04_FLOOR1_BANK_PATH, 1)


func load_zone04_floor2_bank() -> bool:
	return _load_bank(ZONE04_FLOOR2_BANK_PATH, 2)


func load_zone04_floor3_bank() -> bool:
	return _load_bank(ZONE04_FLOOR3_BANK_PATH, 3)


func load_zone04_floor4_bank() -> bool:
	return _load_bank(ZONE04_FLOOR4_BANK_PATH, 4)


func _load_bank(path: String, floor_number: int) -> bool:
	current_floor = floor_number
	if not FileAccess.file_exists(path):
		push_error("QuizController: bank not found: %s" % path)
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("QuizController: cannot open %s" % path)
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("QuizController: invalid JSON root in %s" % path)
		return false
	question_bank = data.get("questions", [])
	if question_bank.is_empty():
		push_error("QuizController: empty questions in %s" % path)
		return false
	return true


func start_quiz() -> bool:
	if question_bank.is_empty():
		if not load_floor1_bank():
			return false
	if not _select_session(QUESTIONS_PER_QUIZ):
		return false
	current_index = 0
	score = 0
	_awaiting_advance = false
	_quiz_active = true
	_emit_current_question()
	return true


func retry_quiz() -> bool:
	## Fresh random set of QUESTIONS_PER_QUIZ unique questions.
	return start_quiz()


func is_active() -> bool:
	return _quiz_active


func get_session_total() -> int:
	return session_questions.size()


func get_score() -> int:
	return score


func get_percent() -> float:
	var total := float(session_questions.size())
	if total <= 0.0:
		return 0.0
	return (float(score) / total) * 100.0


func get_current_question() -> Dictionary:
	return current_question


func submit_option_text(selected_text: String) -> void:
	if not _quiz_active or _awaiting_advance:
		return
	if current_question.is_empty():
		return
	_awaiting_advance = true
	var correct_text := _effective_correct_answer(current_question)
	var is_correct := selected_text == correct_text
	if is_correct:
		score += 1
	var explanation := str(current_question.get("explanation", ""))
	answer_resolved.emit(is_correct, explanation)


func submit_text_answer(raw_text: String) -> void:
	## one_word / free-text answers. Uses accepted_answers when present.
	if not _quiz_active or _awaiting_advance:
		return
	if current_question.is_empty():
		return
	_awaiting_advance = true
	var typed := raw_text.strip_edges()
	var is_correct := false
	if demo_first_option_is_correct and _is_one_word(current_question):
		# Demo parity with MCQ "always pick A": any non-empty answer passes.
		is_correct = not typed.is_empty()
	else:
		is_correct = _matches_accepted_answer(typed, current_question)
	if is_correct:
		score += 1
	var explanation := str(current_question.get("explanation", ""))
	answer_resolved.emit(is_correct, explanation)


func advance_after_feedback() -> void:
	if not _quiz_active:
		return
	_awaiting_advance = false
	current_index += 1
	if current_index >= session_questions.size():
		_finish_quiz()
	else:
		_emit_current_question()


func _select_session(count: int) -> bool:
	var pool: Array = []
	for q in question_bank:
		if typeof(q) == TYPE_DICTIONARY:
			pool.append(q)
	if pool.size() < count:
		push_error("QuizController: need %d questions, bank has %d" % [count, pool.size()])
		return false
	pool.shuffle()
	session_questions = pool.slice(0, count)
	# Guarantee unique ids within session
	var seen: Dictionary = {}
	for q in session_questions:
		var qid := str(q.get("id", ""))
		if qid.is_empty():
			continue
		if seen.has(qid):
			push_error("QuizController: duplicate id in session: %s" % qid)
			return false
		seen[qid] = true
	return session_questions.size() == count


func _emit_current_question() -> void:
	current_question = session_questions[current_index]
	question_changed.emit(current_index, session_questions.size(), current_question)


func _is_one_word(question: Dictionary) -> bool:
	var fmt := str(question.get("format", "")).to_lower()
	if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
		return true
	var options = question.get("options", null)
	return not (options is Array and options.size() > 0)


func _effective_correct_answer(question: Dictionary) -> String:
	if demo_first_option_is_correct:
		var options = question.get("options", [])
		if options is Array and options.size() > 0:
			return str(options[0])
	if question.has("correct_answer"):
		return str(question["correct_answer"])
	return str(question.get("answer", ""))


func _matches_accepted_answer(typed: String, question: Dictionary) -> bool:
	if typed.is_empty():
		return false
	var normalized := typed.to_lower()
	var accepted = question.get("accepted_answers", null)
	if accepted is Array and accepted.size() > 0:
		for a in accepted:
			if normalized == str(a).strip_edges().to_lower():
				return true
		return false
	var correct := str(question.get("correct_answer", "")).strip_edges().to_lower()
	return not correct.is_empty() and normalized == correct


func _finish_quiz() -> void:
	_quiz_active = false
	_awaiting_advance = false
	var total := session_questions.size()
	var percent := get_percent()
	var passed := total > 0 and float(score) >= float(total) * PASS_THRESHOLD
	if passed:
		quiz_passed.emit(score, total, percent)
	else:
		quiz_failed.emit(score, total, percent)

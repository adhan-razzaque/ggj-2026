class_name Level extends Node

# Signals
signal success_phrase(phrase: String)
signal round_begun(new_round: Round)
signal new_player_selected(new_player: FlagHolders)
signal new_answer_selected(new_answer: FlagHolders)
signal new_choice_selected(new_choice: FlagHolders)
signal level_complete()
signal level_lost(score: int)
signal level_lives_changed(lives_left: int)

# Properties
@export_file("*.txt") var success_phrases_path: String
@export_file("*.tscn") var next_scene_path: String
@export var autostart: bool = true
@export var endless: bool = false
@export var lives: int = 3


# Variables
var success_phrases: Array[String] = []
var rounds: Array[Round] = []
var current_round_index: int = -1
var score: int = 0
@onready var timer: Timer = $Timer as Timer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

const save_file_path: String = "user://flag_jam.save"
const save_section: String = "save"

var current_round: Round:
	get:
		return rounds[current_round_index]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_success_phrases()
	load_rounds()
	next_round()
	audio_player.play()

## Load the success phrases from the provided text file
func load_success_phrases() -> void:
	if (success_phrases_path.is_empty()):
		print_debug("Success Phrases path is empty")
		return
		
	if (!FileAccess.file_exists(success_phrases_path)):
		print_debug("Success Phrases path does not exist")
		return
		
	var file := FileAccess.open(success_phrases_path, FileAccess.READ)
	
	var line: String = file.get_line()
	
	while (!line.is_empty()):
		success_phrases.append(line)
		line = file.get_line()
	
## Load the rounds from the children of this node
func load_rounds() -> void:
	var children: Array[Node] = get_children()
	
	for child: Node in children:
		var round_node: Round = child as Round
		if round_node == null:
			continue
		print_debug("Loading round " + round_node.name)
		rounds.append(round_node)
		
## Start the next round
func next_round() -> void:
	if endless:
		current_round.randomize_round()
	else:
		if current_round_index + 1 == rounds.size():
			end_level()
			return
		current_round_index += 1
	
	if not autostart:
		return
	
	start_round()
	
func start_round() -> void:
	current_round.round_over.connect(_on_round_over)
	current_round.player_state_changed.connect(_on_player_state_changed)
	round_begun.emit(current_round)
	current_round.start_game()
	timer.start()
	new_player_selected.emit(current_round.current_flags)
	new_answer_selected.emit(current_round.correct_answer)
	new_choice_selected.emit(current_round.answer_choice)
		
## End Level
func end_level() -> void:
	print_debug("You reached end of level...")
	level_complete.emit()
	audio_player.stop()
	save_score()
	
	if next_scene_path.is_empty or !FileAccess.file_exists(next_scene_path):
		print_debug("not switching scenes")
		return
		
	print_debug("Switching to next scene")
	get_tree().change_scene_to_file(next_scene_path)
	

## Responds to our timers timeout
func _on_timer_timeout() -> void:
	current_round.on_tick()

func _on_round_over(won: bool) -> void:
	timer.stop()
	current_round.round_over.disconnect(_on_round_over)
	current_round.player_state_changed.disconnect(_on_player_state_changed)
	
	if won:
		print_debug("You won, moving to next round...")
		var success_string: String = success_phrases.pick_random()
		success_phrase.emit(success_string)
		score += 1
		next_round()
		return
	
	if endless:
		lives -= 1
		level_lives_changed.emit(lives)
		if lives == 0:
			level_lost.emit(score)
			end_level()
			return
	
	print_debug("You lost, try again...")
	start_round()
		
func _on_player_state_changed(new_state: FlagHolders) -> void:
	new_player_selected.emit(new_state)
	
func get_saved_high_score() -> int:
	if not FileAccess.file_exists(save_file_path):
		return 0
	
	var save = ConfigFile.new()
	save.load(save_file_path)
	
	return save.get_value(save_section, "high_score", 0) as int
	
	
func save_score() -> void:
	var save = ConfigFile.new()
	var high_score: int = get_saved_high_score()
	high_score = max(score, high_score)
	
	save.set_value(save_section, "high_score", high_score)
	save.set_value(save_section, "score", score)
	save.save(save_file_path)
	

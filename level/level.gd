class_name Level extends Node

# Signals
signal success_phrase(phrase: String)
signal round_begun(new_round: Round)
signal new_player_selected(new_player: FlagHolders)
signal new_answer_selected(new_answer: FlagHolders)
signal new_choice_selected(new_choice: FlagHolders)

# Properties
@export_file("*.txt") var success_phrases_path: String
@export_file("*.tscn") var next_scene_path: String


# Variables
var success_phrases: Array[String] = []
var rounds: Array[Round] = []
var current_round_index: int = -1
@onready var timer: Timer = $Timer as Timer

var current_round: Round:
	get:
		return rounds[current_round_index]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_success_phrases()
	load_rounds()
	
	var start_timer = get_tree().create_timer(3.0)
	start_timer.timeout.connect(next_round)

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
	if current_round_index + 1 == rounds.size():
		end_level()
		return
	current_round_index += 1
	start_round()
	
	
func start_round() -> void:
	current_round.round_over.connect(_on_round_over)
	current_round.player_state_changed.connect(_on_player_state_changed)
	current_round.start_game()
	timer.start()
	round_begun.emit(current_round)
	new_player_selected.emit(current_round.current_flags)
	new_answer_selected.emit(current_round.correct_answer)
	new_choice_selected.emit(current_round.answer_choice)
		
## End Level
func end_level() -> void:
	if next_scene_path.is_empty or !FileAccess.file_exists(next_scene_path):
		return
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
		next_round()
	else:
		print_debug("You lost, try again...")
		start_round()
		
func _on_player_state_changed(new_state: FlagHolders) -> void:
	new_player_selected.emit(new_state)

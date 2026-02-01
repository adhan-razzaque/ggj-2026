class_name Round extends Node

# Signals

## Signals that round is completed, won is whenever the game was won or not
signal round_over(won: bool)

## Signals that wall has moved, new_position is the position it is now at
signal wall_moved(new_position: int)

## Signals that current flags changed
signal player_state_changed(new_state: FlagHolders)

# Enums
## The operators that can be used within a round
enum Operators {
	## Bitwise OR; |
	OR,
	## Bitwise AND; &
	AND,
	## Bitwise XOR; ^
	XOR,
}

# Properties

## The correct answer for this round, typically a binary literals ex: 0b1010
@export var correct_answer: FlagHolders

## The value the players starts with for this round, typically binary literal
@export var start_point: FlagHolders

## The answer choices to provide
@export var answer_choice: FlagHolders

## The operators available for use this round; duplicates ignored if ordered is not checked
@export var operators: Array[Operators]

## If checked, player must respond apply operators as ordered; otherwise any can be used
@export var is_ordered: bool

## The rate at which the wall moves with the tick rate; does not move at 0
@export_range(0, 1, 0.01, "suffix:steps") var wall_movement_rate: float = 0.

## That limit wall can reach before game is over
@export var wall_limit: int = 10

@export var wall_move_delay: float = 3.0

@export_category("Endless Mode")

@export var min_iterations: int = 2
@export var max_target_iterations: int = 5
@export_range(0, 1, 0.01, "suffix:steps") var max_wall_rate: float = 1.0
@export var wall_rate_increase_step: float = 0.1

# Variables

## Tracks wall movement rate to decide when to move to next step
var wall_tick: float = 0.

var _wall_position: int = 0

## Tracks where wall is currently at
var wall_position: int:
	get:
		return _wall_position
	set(value):
		wall_moved.emit(value)
		_wall_position = value

## Tracks whether round is in progress
var round_active: bool

## The current state of round flags
var current_flags: FlagHolders

var wall_moving: bool

# Methods

func _ready() -> void:
	validate_round()
	current_flags = FlagHolders.new()
	add_child(current_flags)

## Validates whether this round is in good format
func validate_round() -> void:
	var widths_dont_match: bool = correct_answer.width != start_point.width
	if widths_dont_match:
		print_debug("Bit Widths don't match between answers and starting point")

## Resets relevant state and begins game
func start_game() -> void:
	print_debug("Starting round")
	wall_tick = 0.
	wall_position = 0
	reset_answer()
	round_active = true
	
	if wall_move_delay == 0.:
		wall_moving = true
	else:
		wall_moving = false
		var start_timer = get_tree().create_timer(wall_move_delay)
		start_timer.timeout.connect(func (): wall_moving = true)
	

func end_game(round_won: bool) -> void:
	var output_state: String = "Round won" if round_won else "Round lost"
	print_debug(output_state)
	round_active = false
	round_over.emit(round_won)

## Performs all the clock tick actions
func on_tick() -> void:
	if (!round_active):
		print_debug("Received tick but round is not active.")
		return
	
	wall_tick += wall_movement_rate
	
	if (wall_tick < 1.):
		return
	
	var wall_movement: int = floori(wall_tick)
	print_debug("Moving wall by %f" % wall_movement)
	wall_position += wall_movement
	wall_tick -= wall_movement
	
	var wall_at_end: bool = !(wall_position < wall_limit)
	if (!wall_at_end):
		return
		
	var won_round: bool = current_flags.flags == correct_answer.flags
	end_game(won_round)
	
## Resets stored answer to the start point
func reset_answer() -> void:
	current_flags.flags = start_point.flags
	current_flags.width = start_point.width
	
## Submits answer choice at index with provided operator
func submit_answer(operator: Operators) -> void:
	if (operator not in operators):
		print_debug("Operator %s was not in the list of choices" % Operators.find_key(operator))
		return
		
	print_debug(current_flags.flags)
	current_flags.flags = apply_operator(operator, current_flags.flags, answer_choice.flags)
	current_flags.flags &= current_flags.width_mask
	print_debug(current_flags.flags)
	player_state_changed.emit(current_flags)
	
	
func apply_operator(operator: Operators, lhs: int, rhs: int) -> int:
	match operator:
		Operators.OR:
			return lhs | rhs
		Operators.AND:
			return lhs & rhs
		Operators.XOR:
			return lhs ^ rhs
		_:
			print_debug("Invalid operator provided")
	push_error("Invalid operator provided")
	return 0
	
func increase_wall_rate() -> void:
	wall_movement_rate += wall_rate_increase_step
	wall_movement_rate = min(wall_movement_rate, max_wall_rate)
	
func randomize_round() -> void:
	start_point.randomize_flags()
	answer_choice.randomize_flags()
	
	var iterations: int = randi_range(min_iterations, max_target_iterations)
	var result: int = start_point.flags
	for x in range(iterations):
		var random_operator: Operators = operators.pick_random()
		result = apply_operator(random_operator, result, answer_choice.flags)
		result &= start_point.width_mask
		
	# few more iterations if we land at the same value
	while result == start_point.flags:
		var random_operator: Operators = operators.pick_random()
		result = apply_operator(random_operator, result, answer_choice.flags)
		result &= start_point.width_mask
		
	correct_answer.flags = result
	

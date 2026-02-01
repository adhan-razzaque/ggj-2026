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
@export_range(0, 4, 0.25, "suffix:steps") var wall_movement_rate: float = 0.

## That limit wall can reach before game is over
@export var wall_limit: int = 10

# Variables

## Tracks wall movement rate to decide when to move to next step
var wall_tick: float = 0.

## Tracks where wall is currently at
var wall_position: int = 0

## Tracks whether round is in progress
var round_active: bool

## The current state of round flags
var current_flags: FlagHolders

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
	wall_moved.emit(wall_position)
	wall_tick -= wall_movement
	
	var lost_round: bool = !(wall_position < wall_limit)
	if (!lost_round):
		return
		
	end_game(lost_round)
	
## Resets stored answer to the start point
func reset_answer() -> void:
	current_flags.flags = start_point.flags
	current_flags.width = start_point.width
	
## Submits answer choice at index with provided operator
func submit_answer(operator: Operators) -> void:
	if (operator not in operators):
		print_debug("Operator %s was not in the list of choices" % Operators.find_key(operator))
		return
		
	match operator:
		Operators.OR:
			current_flags.flags |= answer_choice.flags
		Operators.AND:
			current_flags.flags &= answer_choice.flags
		Operators.XOR:
			current_flags.flags ^= answer_choice.flags
		_:
			print_debug("Invalid operator provided")
			return
			
	player_state_changed.emit(current_flags)
			
	var won_round: bool = current_flags.flags == correct_answer.flags
	if (!won_round):
		return
	
	end_game(won_round)

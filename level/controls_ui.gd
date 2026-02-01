class_name ControlsUI extends Control

@export var operator_container: Container
@export var choice_container: Container
@export var submit_button: Button
@export var reset_button: Button
@export var operator_button_group: ButtonGroup

var current_round: Round
var current_operator: Round.Operators
var pressed_once: bool

func _ready() -> void:
	submit_button.pressed.connect(on_submit_pressed)
	reset_button.pressed.connect(on_reset_pressed)
	clear_operators()
	submit_button.hide()
	
func clear_operators() -> void:
	var children := operator_container.get_children()
	children.append_array(choice_container.get_children())
	for child: Node in children:
		child.queue_free()

func on_round_begun(new_round: Round) -> void:
	pressed_once = false
	current_round = new_round
	clear_operators()
	submit_button.show()
	
	for operator in new_round.operators:	
		var button: Button = Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.text = Round.Operators.find_key(operator)
		button.button_group = operator_button_group
		
		match operator:
			Round.Operators.OR:
				button.pressed.connect(on_or_pressed)
			Round.Operators.AND:
				button.pressed.connect(on_and_pressed)
			Round.Operators.XOR:
				button.pressed.connect(on_xor_pressed)
				
		operator_container.add_child(button)
		
func on_or_pressed() -> void:
	current_operator = Round.Operators.OR
	pressed_once = true
	
func on_and_pressed() -> void:
	current_operator = Round.Operators.AND
	pressed_once = true
	
func on_xor_pressed() -> void:
	current_operator = Round.Operators.XOR
	pressed_once = true

func on_submit_pressed() -> void:
	if not pressed_once:
		return
	current_round.submit_answer(current_operator)
	
func on_reset_pressed() -> void:
	current_round.reset_answer()

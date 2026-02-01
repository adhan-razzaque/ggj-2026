class_name ControlsUI extends Control

@export var operator_container: Container
@export var choice_container: Container
@export var submit_button: Button
@export var operator_button_group: ButtonGroup
@export var choice_button_group: ButtonGroup

var current_round: Round

func _ready() -> void:
	submit_button.pressed.connect(on_submit_pressed)

func on_round_begun(new_round: Round) -> void:
	var children := operator_container.get_children()
	children.append_array(choice_container.get_children())
	for child: Node in children:
		child.queue_free()
		
	var button: Button = Button.new()
	
		

func on_submit_pressed() -> void:
	current_round.submit_answer(0, 0)

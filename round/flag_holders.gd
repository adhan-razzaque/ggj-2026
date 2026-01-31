class_name FlagHolders extends Node

# Variables

## Binary literal to represent flag choices (red flag, green flag)
@export_flags("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight")
var flags: int = 0b0

## The number of flag holders in this, aka the bit width
@export_range(0, 8) var width: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

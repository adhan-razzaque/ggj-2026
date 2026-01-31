class_name FlagHolders extends Node

# Variables

## Binary literal to represent flag choices (red flag, green flag)
@export_flags("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight")
var flags: int = 0b0

## The number of flag holders in this, aka the bit width
@export_range(0, 8) var width: int = 0

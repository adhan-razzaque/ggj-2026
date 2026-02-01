class_name FlagHolders extends Node
## Represents flag holders in a simple and editor-friendly format

# Constants
const MAX_WIDTH: int = 8

# Variables

## Binary literal to represent flag choices (red flag, green flag)
@export_flags("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight")
var flags: int

## The number of flag holders in this, aka the bit width
@export_range(1, MAX_WIDTH) var width: int

var width_mask: int:
	get:
		return (1 << width) - 1

## Constructor.
## init_flags is a binary value where 1 corresponds to green flag and 0 corresponds
## to red flag, should be no longer than MAX_WIDTH bits wide.
## set_width is the number of flag holders to use, i.e, the bit width, should be no
## no more than MAX_WIDTH
func _init(init_flags: int = 0b0, set_width: int = 1):
	if (set_width > MAX_WIDTH):
		print_debug("Bit width is too large, capping to max width")
		set_width = max(set_width, MAX_WIDTH)
	if ((init_flags & ~width_mask) > 0):
		print_debug("Flags is too large, masking to max width")
		init_flags = init_flags & width_mask
	
	self.flags = init_flags
	self.width = set_width
	
func randomize_flags():
	flags = randi() & width_mask
	

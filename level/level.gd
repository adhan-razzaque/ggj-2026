class_name Level extends Node


# Properties
@export_file("*.txt") var success_phrases_path: String

# Variables
var success_phrases: Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_success_phrases()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	

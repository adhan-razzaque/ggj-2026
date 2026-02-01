class_name ScoreDisplay extends Control

@export_file_path var main_menu_path: String
@export var score_label: Label

const save_file_path: String = "user://flag_jam.save"
const save_section: String = "save"

const score_output_format := "Your Score:\n%d\nHigh Score:\n%d"

func _ready() -> void:
	set_saved_values()

func set_saved_values() -> void:
	if not FileAccess.file_exists(save_file_path):
		score_label.text = score_output_format % [0, 0]
		return
	
	var save = ConfigFile.new()
	save.load(save_file_path)
	
	var score = save.get_value(save_section, "score", 0) as int
	var high_score = save.get_value(save_section, "high_score", 0) as int
	
	score_label.text = score_output_format % [score, high_score]


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)

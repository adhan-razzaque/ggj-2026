extends Control

@export_file_path("*.tscn") var main_menu: String

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu)

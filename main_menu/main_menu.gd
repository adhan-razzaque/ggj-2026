class_name MainMenu extends Control

@export_file_path("*.tscn") var first_level_path: String
@export_file_path("*.tscn") var credits_path: String


@export var start_button: BaseButton
@export var credits_button: BaseButton
@export var exit_button: BaseButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	if OS.get_name() == "Web":
		exit_button.hide()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(first_level_path)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(credits_path)


func _on_exit_pressed() -> void:
	get_tree().quit()

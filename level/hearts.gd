class_name Hearts extends Node2D

@export var hearts: Array[Sprite2D]

func _on_lives_changed(lives_left: int) -> void:
	print_debug("Setting Hearts %d" % lives_left)
	for heart: Sprite2D in hearts:
		if lives_left > 0:
			heart.show()
		else:
			heart.hide()
		lives_left -= 1

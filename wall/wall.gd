class_name Wall extends Node2D

@onready var line: Line2D = $Line2D
@onready var wall_sprite: Sprite2D = $WallSprite

var line_splits = 8
var current_round: Round

func _ready() -> void:
	wall_sprite.position = line.get_point_position(0)

func on_wall_moved(new_position: int) -> void:
	var start: Vector2 = line.get_point_position(0)
	var end: Vector2 = line.get_point_position(1)
	var distance: Vector2 = end - start
	distance *= float(new_position) / line_splits
	wall_sprite.position = start + distance
	
func on_round_begun(new_round: Round) -> void:
	if current_round != null:
		current_round.wall_moved.disconnect(on_wall_moved)
		
	current_round = new_round
	line_splits = current_round.wall_limit
	current_round.wall_moved.connect(on_wall_moved)
	

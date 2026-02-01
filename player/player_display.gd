class_name PlayerDisplay extends Container

## 2 sprites to index to with 1 bit value
@export var sprites_1bit: Array[CompressedTexture2D]

## 4 sprites to index to with 2 bit value
@export var sprites_2bit: Array[CompressedTexture2D]

@onready var hbox_container: HBoxContainer = $HBoxContainer

var _flags: FlagHolders
var flags: FlagHolders:
	get:
		return _flags
	set(value):
		_flags = value
		build_player_texture(value)


func _ready() -> void:
	var test = FlagHolders.new()
	test.width = 4
	test.flags = 3
	flags = test


func build_player_texture(from_flags: FlagHolders) -> void:
	var children := hbox_container.get_children()
	
	for child in children:
		child.queue_free()
		
	var texture_count: int = ceili(from_flags.width / 2.0)
	var value: int = from_flags.flags
	var width: int = from_flags.width
	var texture_rects: Array[TextureRect] = []
	
	for i in range(texture_count):
		var new_texture = TextureRect.new()
		var this_value: int = value & 0b11
		value >>= 2
		new_texture.texture = sprite_from_value(this_value, width == 1)
		new_texture.size = Vector2(32, 32)
		width -= 2
		texture_rects.push_front(new_texture)
		
	for texture_rect in texture_rects:
		hbox_container.add_child(texture_rect)
	
## Returns the sprite from the 2 bit value
func sprite_from_value(value: int, one_bit: bool = false) -> CompressedTexture2D:
	if value < 0 or value > 0b11:
		print_debug("Received an invalid value")
		return null
		
	if one_bit:
		value &= 0b1
		return sprites_1bit[value]
	
	return sprites_2bit[value]

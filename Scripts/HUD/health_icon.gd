extends TextureRect

@export var sprites: Array[Texture2D]

func change_sprite(value: int):
	texture = sprites[value]


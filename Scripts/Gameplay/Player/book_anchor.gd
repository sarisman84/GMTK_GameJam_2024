extends Node2D

func switch_face(direction: int) -> void:
	if direction > 0:
		position.x = -abs(position.x)
	else:
		position.x = abs(position.x)

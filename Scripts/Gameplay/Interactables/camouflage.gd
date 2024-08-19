class_name Camouflage
extends Sprite2D


@export var transition_duration_in_seconds : float = 0.5

func enable() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(



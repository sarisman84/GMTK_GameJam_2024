extends Area2D

@export var end_scene : PackedScene


func _on_body_entered(body):
	if body is CharacterBody2D:
		get_tree().call_deferred("change_scene_to_packed", end_scene)


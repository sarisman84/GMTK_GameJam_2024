extends Node

@export var test : Node2D

func _ready() -> void:
	Onboarding.enable_popup_at(test,"Press [key:interact] and [key:dash] and [key:mouse] to pick this up")

func _process(delta):
	pass

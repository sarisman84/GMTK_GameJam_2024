extends Node2D

@export var smoothing : float = 0.25
@export var target_to_follow : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	global_position = lerp(global_position, target_to_follow.global_position, smoothing * _delta)

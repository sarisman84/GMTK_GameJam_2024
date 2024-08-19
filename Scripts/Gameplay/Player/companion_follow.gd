extends Node2D

@export var smoothing : float = 0.25
@export var target_to_follow : Node2D

@onready var m_animation = $AnimatedSprite2D

#TODO: Scaling

# Called when the node enters the scene tree for the first time.
func _ready():
	m_animation.play()

#Dai: Yes I know this is scuffed.
#TODO: Position.x part will probably have to be replaced so scaling works.
func switch_face(direction: int) -> void:
	if direction > 0:
		m_animation.flip_h = false
		position.x = -24
	else:
		m_animation.flip_h = true
		position.x = 24

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	#global_position = lerp(global_position, target_to_follow.global_position, smoothing * _delta)
	pass

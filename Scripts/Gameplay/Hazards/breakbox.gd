extends Node2D

@export var m_max_health : int = 5 #TODO: Change health based on Player's Attack
@onready var m_health : HealthNode = $health

func _ready() -> void:
	m_health.set_max_health(m_max_health)
	m_health.on_death.connect(m_on_hazard_death)

func m_on_hazard_death() -> void:
	queue_free()

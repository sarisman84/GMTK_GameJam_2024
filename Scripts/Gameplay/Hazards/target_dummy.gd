extends Node2D

@export var max_health : int = 100
@onready var health = $health

# Called when the node enters the scene tree for the first time.
func _ready():
	health.set_health_node_owner(self)
	health.set_max_health(max_health)
	health.on_death.connect(m_self_destruct)


func m_self_destruct() -> void:
	queue_free()

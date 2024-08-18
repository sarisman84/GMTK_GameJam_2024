extends Node2D

@export var m_max_health : int = 5 #TODO: Change health based on Player's Attack
@export var causes_damage: bool = true
@export var damage_level: int = 1
@export var m_health_regeneration_points : int = 1
@onready var m_health : HealthNode = $health


func _ready() -> void:
	m_health.set_max_health(m_max_health)
	m_health.on_death.connect(m_on_hazard_death)

func m_on_hazard_death() -> void:
	HealthRegenBar.update_points(m_health_regeneration_points)
	queue_free()

func _on_area_2d_body_entered(body):
	if body.name == "player_avatar" and causes_damage == true:
		body.get_node("health").apply_damage(damage_level)
		#TODO: player should recoil from damage (might be true for non-static damage as well)


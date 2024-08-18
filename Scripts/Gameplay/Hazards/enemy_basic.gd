extends CharacterBody2D

@export var m_max_health : int = 5 #TODO: Change health based on Player's Attack
@export var m_health_regeneration_points : int = 1
@onready var m_health : HealthNode = $health

var m_speed : float = 60
var m_gravity : float = 14
var m_dir : float = 1.0

func _ready() -> void:
	m_health.set_max_health(m_max_health)
	m_health.on_death.connect(m_on_hazard_death)

func m_on_hazard_death() -> void:
	HealthRegenBar.update_points(m_health_regeneration_points)
	queue_free()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += m_gravity

	velocity.x = m_speed * m_dir
	move_and_slide()

	if is_on_wall():
		m_dir = -m_dir

extends StaticBody2D
class_name HealthNode

signal on_death
signal on_damage_taken

@onready var m_hurtbox = $hurtbox

var m_max_health : int
var m_current_health : float = -1
var m_owner : Node2D
var m_default_scale : Vector2

func _ready() -> void:
	m_default_scale = m_hurtbox.scale

func reset_health() -> void:
	m_current_health = m_max_health

func set_health_node_owner(node : Node2D) -> void:
	m_owner = node

func set_max_health(target_max_health : int) -> void:
	m_max_health = target_max_health
	# If the current health was not set to anything beyond 0, apply the max health again to it
	if m_current_health <= 0:
		m_current_health = m_max_health

func set_current_health(new_health: int) -> void:
	m_current_health = new_health

func apply_damage(incoming_damage : float) -> void:
	if m_current_health <= 0:
		return
	on_damage_taken.emit()
	m_current_health -= incoming_damage
	if m_current_health <= 0:
		on_death.emit()
	if m_current_health > m_max_health:
		m_current_health = m_max_health

func scale_hitbox(new_scale : float) -> void:
	m_hurtbox.scale = m_default_scale * new_scale


func get_max_health() -> int:
	return m_max_health


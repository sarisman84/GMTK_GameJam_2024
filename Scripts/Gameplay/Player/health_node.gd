extends StaticBody2D
class_name HealthNode

signal on_death
var m_current_health : float = -1
var m_max_health : int

func set_max_health(start_health : int) -> void:
	m_max_health = start_health
	if m_current_health < 0:
		m_current_health = m_max_health


func on_damage_taken(incoming_damage : float) -> void:
	if m_current_health <= 0:
		return

	m_current_health -= incoming_damage
	if m_current_health <= 0:
		on_death.emit()



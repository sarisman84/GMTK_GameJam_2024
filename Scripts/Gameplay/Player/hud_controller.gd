extends CanvasLayer

@onready var m_energy_bar : ProgressBar = $energybar

var m_health_array : Array[TextureRect]
var m_max_health : int = 6
var m_health : int = 6


func _ready():
	for icon in $Health.get_children():
		m_health_array.append(icon)
	reset()

func reset():
	for icon in m_health_array:
		icon.change_sprite(2)
	m_health = m_max_health

func take_damage():
	if m_health > 0:
		m_health -= 1
		m_health_array[m_health/2].change_sprite(m_health%2)

func heal():
	if m_health < m_max_health:
		m_health_array[m_health/2].change_sprite((m_health%2)+1)
		m_health += 1

func set_max_energy(max_energy) -> void:
	m_energy_bar.max_value = max_energy

func set_energy(cur_energy) -> void:
	m_energy_bar.value = cur_energy

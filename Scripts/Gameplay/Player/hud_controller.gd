extends CanvasLayer

@onready var m_health_bar : ProgressBar = $healthbar
@onready var m_energy_bar : ProgressBar = $energybar

func set_max_health(max_health) -> void:
	m_health_bar.max_value = max_health

func set_health(cur_health) -> void:
	m_health_bar.value = cur_health

func set_max_energy(max_energy) -> void:
	m_energy_bar.max_value = max_energy

func set_energy(cur_energy) -> void:
	m_energy_bar.value = cur_energy

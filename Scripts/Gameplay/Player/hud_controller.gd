extends CanvasLayer

var m_health_array : Array[TextureRect]
var m_max_health : int = 6
var m_health : int = 6

func _ready():
	for icon in $Health.get_children():
		icon.hide()
		m_health_array.append(icon)
	#Debug:
	update_max_health(6)
	await get_tree().create_timer(1.5).timeout
	update_max_health(12)
	update_current_health(9)
	await get_tree().create_timer(1.5).timeout
	update_max_health(2)
	update_current_health(1)
	await get_tree().create_timer(1.5).timeout
	update_max_health(6)
	update_current_health(3)

func reset_visuals():
	for node in m_health_array:
		node.texture = node.sprites[2]

func update_max_health(value: int):
	var num = ceil(value/2.0)
	for i in 6:
		if i < num:
			m_health_array[i].show()
		else:
			m_health_array[i].hide()
	m_max_health = value

func update_current_health(value: int):
	m_health = m_max_health
	reset_visuals()
	for i in m_max_health - value:
		hud_take_damage()

func hud_take_damage():
	if m_health > 0:
		m_health -= 1
		m_health_array[m_health/2].change_sprite(m_health%2)

func hud_heal():
	if m_health < m_max_health:
		m_health_array[m_health/2].change_sprite((m_health%2)+1)
		m_health += 1

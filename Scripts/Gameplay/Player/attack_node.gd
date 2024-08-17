extends Area2D
class_name AttackNode

@onready var m_hitbox = $hitbox

var m_target_pos: Vector2
var m_default_hitbox_scale : Vector2
var m_current_targets: Array[HealthNode]

var m_cur_rate: float
var m_scaled_pos : Vector2
var m_current_dir : int


func _ready() -> void:
	m_default_hitbox_scale = m_hitbox.scale
	m_target_pos = m_hitbox.position
	m_hitbox.position = Vector2.ZERO
	body_entered.connect(m_on_entity_enter)
	body_exited.connect(m_on_entity_exit)
	pass

func _process(_delta) -> void:
	m_cur_rate -= _delta
	m_cur_rate = max(m_cur_rate, 0)


func scale_hitbox(scale_multiplier : float) -> void:
	m_scaled_pos = m_target_pos * scale_multiplier
	m_hitbox.scale = m_default_hitbox_scale * scale_multiplier
	switch_face(m_current_dir)


func switch_face(_direction: int) -> void:
	m_current_dir = _direction
	m_hitbox.position = m_scaled_pos * m_current_dir

func attack_current_targets(attack_damage: float, attack_rate_in_seconds: float) -> void:
	if m_cur_rate <= 0:
		for i in range(m_current_targets.size()):
			var target = m_current_targets[i]
			#Should the entry be invalid, remove it and continue
			if not target:
				m_current_targets.remove_at(i)
				continue
			target.apply_damage(attack_damage)
			m_cur_rate = attack_rate_in_seconds



func m_on_entity_enter(_body: Variant) -> void:
	if not _body is HealthNode:
		return
	var m_hn = _body as HealthNode
	# Skip adding yourself to the list of targets to attack
	if m_hn.owner.get_path() == self.get_parent().get_path():
		return
	m_current_targets.append(m_hn)

func m_on_entity_exit(_body: Variant) -> void:
	if not _body is HealthNode:
		return
	var m_hn = _body as HealthNode
	# Skip removing yourself from the list of targets to attack
	if not m_hn.owner or m_hn.owner.get_path() == self.get_parent().get_path():
		return
	m_current_targets.erase(m_hn)

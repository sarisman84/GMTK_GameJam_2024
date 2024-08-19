class_name Door2D
extends StaticBody2D

@export var open_animation_duration_in_seconds: float = 1
@export var open_position_node2d: Node2D

var m_closed_position: Vector2
var m_tween: Tween
var m_is_open_flag: bool

func _ready() -> void:
	m_closed_position = global_position

	#m_tween.bind_node(self)

func open() -> void:
	if m_is_open_flag:
		return
	m_is_open_flag = true
	m_tween = get_tree().create_tween()
	m_tween.tween_property(self, "global_position", open_position_node2d.global_position, open_animation_duration_in_seconds)

func is_open() -> bool:
	return m_is_open_flag

func close() -> void:
	if not m_is_open_flag:
		return
	m_is_open_flag = false
	m_tween = get_tree().create_tween()
	m_tween.tween_property(self, "global_position", m_closed_position, open_animation_duration_in_seconds)

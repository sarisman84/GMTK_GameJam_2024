extends Node2D

@export var m_max_bar_capacity : int = 2
@export var m_health_points_regenerated : int = 2
var m_current_points :int = 0

signal enemy_killed

func refill_player_health():
	var player = get_tree().current_scene.find_child("player_avatar")
	player.get_node("health").heal(m_health_points_regenerated)
	m_current_points = 0 ## reset bar


func update_points(delta):
	m_current_points+=delta
	enemy_killed.emit()
	if m_current_points >= m_max_bar_capacity:
		refill_player_health()

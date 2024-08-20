extends Node

@export var m_max_bar_capacity : int = 1
@export var m_health_points_regenerated : int = 3
var m_current_points :int = 0

func _ready():
	pass # Replace with function body.

func refill_player_health():
	var player = get_tree().current_scene.find_child("player_avatar")
	player.get_node("health").apply_damage(m_health_points_regenerated * -1)
	m_current_points = 0 ## reset bar


func update_points(delta):
	m_current_points+=delta
	if m_current_points >= m_max_bar_capacity:
		refill_player_health()

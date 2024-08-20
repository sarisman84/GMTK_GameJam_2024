extends Node2D

@export var causes_damage: bool = true
@export var damage_level: int = 1
@export var m_health_regeneration_points : int = 1

func _on_area_2d_body_entered(body):
	if body.name == "player_avatar" and causes_damage == true:
		body.get_node("health").apply_damage(damage_level)
		#TODO: player should recoil from damage (might be true for non-static damage as well)


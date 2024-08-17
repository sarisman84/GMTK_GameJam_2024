extends Node

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		$player_avatar.m_on_player_death()

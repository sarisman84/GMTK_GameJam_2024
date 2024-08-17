extends Area2D

func _on_body_entered(body):
	if body.name == "player_avatar":
		get_node("/root/Global").latest_checkpoint = [get_parent().name, position]
		#For debugging:
		print("checkpoint:")
		print(get_node("/root/Global").latest_checkpoint)

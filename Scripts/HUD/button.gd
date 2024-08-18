extends Button

func _on_mouse_entered():
	$HoverSFX.play()

func _on_pressed():
	$ClickSFX.play()

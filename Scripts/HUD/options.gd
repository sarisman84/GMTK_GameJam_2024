extends CanvasLayer

#TODO: Add sound effect to SFX slider

signal back_button

func _on_back_pressed():
	back_button.emit()

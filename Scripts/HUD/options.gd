extends CanvasLayer

signal back_button

func _on_back_pressed():
	back_button.emit()
	print("pressed")

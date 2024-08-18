extends CanvasLayer

func _ready():
	$options.hide()
	$options.back_button.connect(_on_options_back_pressed)

func _on_start_pressed(): #TODO: Start game
	pass

func _on_options_pressed():
	$title.hide()
	$options.show()

func _on_options_back_pressed():
	print("run")
	$title.show()
	$options.hide()

func _on_quit_pressed():
	get_tree().quit()

extends CanvasLayer

@export var gameplay_scene_path = "res://Scenes/l_gameplay.tscn"
#Has to be path, otherwise it throws an error. Idk why

func _ready():
	$options.hide()
	$options.back_button.connect(_on_options_back_pressed)

func _on_start_pressed(): #TODO: Start game
	get_tree().change_scene_to_file(gameplay_scene_path)

func _on_options_pressed():
	$title.hide()
	$options.show()

func _on_options_back_pressed():
	$title.show()
	$options.hide()

func _on_quit_pressed():
	get_tree().quit()

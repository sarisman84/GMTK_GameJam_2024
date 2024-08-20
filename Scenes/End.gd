extends CanvasLayer

@export var menu_scene : PackedScene
@export var gameplay_scene_path = "res://Scenes/l_gameplay.tscn"
#Has to be path, otherwise it throws an error. Idk why

func _on_quit_to_menu_pressed():
	get_tree().change_scene_to_packed(menu_scene)

func _on_restart_pressed():
	get_tree().change_scene_to_file(gameplay_scene_path)

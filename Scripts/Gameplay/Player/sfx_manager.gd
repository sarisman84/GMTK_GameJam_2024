extends Node
@onready var walking_stream_player = $walking_stream_player

func _ready():
	pass # Replace with function body.

var use_first_list = true
	
func get_sound_list(size):
	var sound_list

	var small_walk_sounds_1 = [
		preload("res://Assets/SFX/walking/sf_small_footstep1_1.mp3"),
		preload("res://Assets/SFX/walking/sf_small_footstep1_2.mp3"),
		preload("res://Assets/SFX/walking/sf_small_footstep1_3.mp3"),
	]
	
	var small_walk_sounds_2 = [
		preload("res://Assets/SFX/walking/sf_small_footstep2_1.mp3"),
		preload("res://Assets/SFX/walking/sf_small_footstep2_2.mp3"),
		preload("res://Assets/SFX/walking/sf_small_footstep2_3.mp3"),
	]
	
	var normal_walk_sounds_1 = [
		preload("res://Assets/SFX/walking/sf_normal_footstep1_1.mp3"),
		preload("res://Assets/SFX/walking/sf_normal_footstep1_2.mp3"),
		preload("res://Assets/SFX/walking/sf_normal_footstep1_3.mp3"),
		preload("res://Assets/SFX/walking/sf_normal_footstep1_4.mp3")
	]
	
	var normal_walk_sounds_2 = [
		preload("res://Assets/SFX/walking/sf_normal_footstep2_1.mp3"),
		preload("res://Assets/SFX/walking/sf_normal_footstep2_2.mp3"),
		preload("res://Assets/SFX/walking/sf_normal_footstep2_3.mp3"),
		preload("res://Assets/SFX/walking/sf_normal_footstep2_4.mp3")
	]
	
	var large_walk_sounds_1 = [
		preload("res://Assets/SFX/walking/sf_large_footstep1_1.mp3"),
		preload("res://Assets/SFX/walking/sf_large_footstep1_2.mp3"),
		preload("res://Assets/SFX/walking/sf_large_footstep1_3.mp3"),
	]
	
	var large_walk_sounds_2 = [
		preload("res://Assets/SFX/walking/sf_large_footstep2_1.mp3"),
		preload("res://Assets/SFX/walking/sf_large_footstep2_2.mp3"),
		preload("res://Assets/SFX/walking/sf_large_footstep2_3.mp3"),

	]
	
	if size == -1:
		return [small_walk_sounds_1, small_walk_sounds_2]
	elif size == 0:
		return [normal_walk_sounds_1, normal_walk_sounds_2]
	else:
		return [large_walk_sounds_1, large_walk_sounds_2]


func m_play_footstep_sound(current_size):
	var lists = get_sound_list(current_size)
	var list_1 = lists[0]
	var list_2 = lists[1]
		
	var sound_list
	if use_first_list:
		sound_list = list_1
	else:
		sound_list = list_2
	use_first_list = !use_first_list  # Alternate between lists

	var next_sound = sound_list[randi() % sound_list.size()]
		
	if !walking_stream_player.is_playing():
		walking_stream_player.pitch_scale = randf() * 0.2 + 0.9
		walking_stream_player.stream = next_sound
		walking_stream_player.play()

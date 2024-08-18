extends Node
@onready var walking_stream_player = $walking_stream_player

func _ready():
	pass # Replace with function body.

var last_played_sound = null

func m_play_walk_sound(current_size):
	var sound_list
	
	var small_walk_sounds = [
		preload("res://Assets/SFX/sf_walking_small_1.wav"),
		preload("res://Assets/SFX/sf_walking_small_2.wav"),
	]
	
	var normal_walk_sounds = [
		preload("res://Assets/SFX/sf_walking_normal_1.wav"),
		preload("res://Assets/SFX/sf_walking_normal_2.wav"),
	]
	
	var large_walk_sounds = [
		preload("res://Assets/SFX/sf_walking_large_1.wav"),
		preload("res://Assets/SFX/sf_walking_large_2.wav"),
	]
	

	if current_size == -1:
		sound_list = small_walk_sounds
	elif current_size == 0:
		sound_list = normal_walk_sounds
	else:
		sound_list = large_walk_sounds

	var next_sound
	if last_played_sound == sound_list[0]:
		next_sound = sound_list[1]
	else:
		next_sound = sound_list[0]

	if !walking_stream_player.is_playing():
		walking_stream_player.pitch_scale = randf() * 0.2 + 0.9
		walking_stream_player.stream = next_sound
		walking_stream_player.play()
		last_played_sound = next_sound

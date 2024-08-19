extends Node2D

@onready var m_companion = $companion
@onready var m_player_avatar = $player_avatar

func _ready():
	m_player_avatar.book_animation.connect(_on_book_animation)

func _process(delta):
	m_companion.m_animation.flip_h = m_player_avatar.m_sprite.flip_h
	

func _on_book_animation():
	m_companion.hide()
	await get_tree().create_timer(0.6666).timeout
	m_companion.show()

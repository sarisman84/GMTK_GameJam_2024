class_name Companion
extends Node2D

@export var smoothing: float = 0.25
@export var target_to_follow: Node2D

@onready var m_idle_animation: AnimatedSprite2D = $sprite
@onready var m_attack_animation = $animation_player
@onready var m_attack_sprite = $attack_sprite

var m_default_scale: Vector2
var m_msg: Variant
var m_default_anchor_pos: Vector2
var m_temp_pos
var m_default_rot : float
var m_offset_pos

var m_override_flip_flag: bool
var m_reset_anim_flag: bool

signal on_book_attack_apex(msg)
signal on_book_attack_start(msg)

#TODO: Scaling

# Called when the node enters the scene tree for the first time.
func _ready():
	m_default_rot = m_attack_sprite.rotation
	m_default_scale = scale
	m_idle_animation.play()
	m_attack_sprite.hide()
	m_attack_animation.animation_finished.connect(m_reset)

func m_reset(_anim_name: StringName) -> void:
	m_override_flip_flag = false
	m_idle_animation.show()
	m_attack_sprite.rotation = m_default_rot


func is_attacking() -> bool:
	return m_attack_animation.is_playing()

func attack(new_position, msg: Variant, offset : Vector2 = Vector2.ZERO) -> void:
	if m_reset_anim_flag:
		m_attack_animation.stop()
		m_reset_anim_flag = false
		pass

	m_idle_animation.hide()
	on_book_attack_start.emit(msg)
	m_temp_pos = new_position
	m_attack_animation.play("book_attack_animation")
	m_offset_pos = offset

	m_msg = msg

func attack_towards(new_position, new_direction: Vector2, msg: Variant) -> void:
	if m_reset_anim_flag:
		m_attack_animation.stop()
		m_reset_anim_flag = false
		pass

	m_idle_animation.hide()
	on_book_attack_start.emit(msg)
	m_override_flip_flag = true
	m_temp_pos = new_position
	m_attack_sprite.flip_h = false
	m_attack_sprite.rotation = new_direction.angle()
	m_attack_animation.play("book_attack_animation")
	m_msg = msg

func enable_canceling() -> void:
	m_reset_anim_flag = true

func change_scale(new_scale: float) -> void:
	if m_default_scale.length() == 0:
		return
	scale = m_default_scale * new_scale

func flip_side(dir: int) -> void:
	if not m_override_flip_flag:
		m_attack_sprite.flip_h = dir < 0
	m_idle_animation.flip_h = dir < 0

func trigger_attack_apex() -> void:
	on_book_attack_apex.emit(m_msg)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	global_position = lerp(global_position, target_to_follow.global_position, smoothing * _delta)
	if m_temp_pos is Vector2:
		m_attack_sprite.global_position = m_temp_pos
	elif m_temp_pos is Node2D:
		m_attack_sprite.global_position = m_temp_pos.global_position + m_offset_pos

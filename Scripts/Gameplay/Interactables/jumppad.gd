class_name JumpPad
extends Area2D

@export var jump_pad_speed: float = 1

var m_physics_objects: Array

func _ready() -> void:
	body_entered.connect(m_on_player_enter)
	body_exited.connect(m_on_player_exit)


func m_on_player_enter(_body: Variant) -> void:
	if _body is PhysicsBody2D or _body is CharacterBody2D:
		m_physics_objects.append(_body)


func m_on_player_exit(_body: Variant) -> void:
	if _body is PhysicsBody2D or _body is CharacterBody2D:
		m_physics_objects.erase(_body)


func _physics_process(_delta: float) -> void:
	for i in range(m_physics_objects.size()):
		var m_p = m_physics_objects[i]
		if m_p is CharacterBody2D:
			m_p.velocity = transform.y * jump_pad_speed
		elif m_p is RigidBody2D:
			m_p.linear_velocity = transform.y * jump_pad_speed
	pass
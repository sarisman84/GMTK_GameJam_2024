class_name InteractNode
extends Area2D


@onready var m_hitbox = $hitbox

var m_target_pos: Vector2
var m_default_hitbox_scale: Vector2
var m_owner: Node2D

var m_current_target_pos : Vector2
var m_current_interactables: Array[Interactable]
var m_current_direction : int

func _ready() -> void:
	m_target_pos = m_hitbox.position
	m_default_hitbox_scale = m_hitbox.scale
	m_owner = get_parent()


func scale_hitbox(scale_multiplier: float) -> void:
	m_hitbox.scale = m_default_hitbox_scale * scale_multiplier
	m_current_target_pos = m_target_pos * scale_multiplier
	switch_face(m_current_direction)

func switch_face(direction : int) -> void:
	m_current_direction = direction
	m_hitbox.position = m_current_target_pos * m_current_direction

func try_to_interact() -> void:
	if m_current_interactables.is_empty():
		return
	for i in range(m_current_interactables.size()):
		var interact = m_current_interactables[i]
		if not interact:
			continue
		interact.on_interact.emit(m_owner)


func _on_body_entered(_body: Variant) -> void:
	if not _body is Interactable:
		return
	var m_interact = _body as Interactable
	m_interact.on_interact_enter.emit(owner)
	m_current_interactables.append(m_interact)



func _on_body_exited(_body: Variant) -> void:
	if not _body is Interactable:
		return
	var m_interact = _body as Interactable
	m_interact.on_interact_exit.emit(owner)
	m_current_interactables.erase(m_interact)

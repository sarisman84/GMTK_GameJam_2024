class_name PickupableNode
extends Node2D

@export var required_size: AvatarController.Size

@onready var m_interactable: Interactable = $interactable
@onready var m_collider: StaticBody2D = $collider
@onready var m_shape : CollisionShape2D = $collider/shape

var m_default_mode : Variant
var m_default_scale: Vector2

func _ready() -> void:
	m_default_scale = scale
	m_interactable.on_interact.connect(m_pickup)
	m_default_mode = m_collider.process_mode


func m_pickup(m_owner: Variant) -> void:
	if m_owner.m_current_size <= required_size:
		m_owner.m_pickup_manager.pick_up_element(self)

func enable_collisions() -> void:
	m_shape.disabled = false


func disable_collisions() -> void:
	m_shape.disabled = true

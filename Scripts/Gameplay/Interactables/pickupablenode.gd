class_name PickupableNode
extends Node2D

@export var required_size: AvatarController.Size

@onready var m_interactable: Interactable = $interactable
@onready var m_collider: StaticBody2D = $collider
@onready var m_shape : CollisionShape2D = $collider/shape
@onready var m_world_checker : Area2D = $world_checker

var m_default_mode : Variant
var m_default_scale: Vector2

var m_popup_id : int = -1
var m_pickup_flag : bool
var m_can_placedown_flag : bool


func _ready() -> void:
	m_interactable.on_interact.connect(m_pickup)
	m_interactable.on_interact_enter.connect(m_show_display_input)
	m_interactable.on_interact_exit.connect(m_hide_display_input)
	m_default_mode = m_collider.process_mode

func m_show_display_input(_owner: Node2D) -> void:
	if m_popup_id == -1:
		m_popup_id = Popups.enable_popup_at(self, "[key:interact]: Pickup")
	else:
		Popups.set_popup_text(m_popup_id, "[key:interact]: Pickup")

func m_hide_display_input(_owner: Node2D) -> void:
	if not m_pickup_flag:
		Popups.disable_popup(m_popup_id)
		m_popup_id = -1

func m_pickup(m_owner: Variant) -> void:
	if m_owner.m_current_size == required_size:
		m_owner.m_pickup_manager.pick_up_element(self)
		m_pickup_flag = true

func enable_collisions() -> void:
	m_shape.disabled = false
	m_pickup_flag = false


func disable_collisions() -> void:
	m_shape.disabled = true


func _on_world_checker_body_entered(body):
	m_can_placedown_flag = false


func _on_world_checker_body_exited(body):
	m_can_placedown_flag = true

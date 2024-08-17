class_name PickupManager
extends Node

var m_picked_element: PickupableNode
var m_owner: Node2D

func init_manager(new_owner : Node2D) -> void:
	m_owner = new_owner
	m_owner.on_size_change.connect(m_scale_pickup)


func pick_up_element(new_element: Node2D) -> void:
	if m_picked_element:
		return
	m_picked_element = new_element as PickupableNode
	m_picked_element.disable_collisions()
	print("picked up ", m_picked_element.name)

func has_picked_up_something() -> bool:
	return m_picked_element != null

func release_picked_up_element() -> void:
	m_picked_element.enable_collisions()
	m_picked_element = null

func _process(_delta) -> void:
	if not m_picked_element:
		return
	m_picked_element.position = m_picked_element.get_global_mouse_position()

func m_scale_pickup(size_id : int, new_scale : float) -> void:
	if not m_picked_element:
		return
	m_picked_element.scale = m_picked_element.m_default_scale * new_scale
	m_picked_element.required_size = size_id as AvatarController.Size


# var cam3D = get_viewport().get_camera_3d()
# 	global_position = cam3D.unproject_position(p.global_position) - size / 2.0
# 	visible = not cam3D.is_position_behind(p.global_position)

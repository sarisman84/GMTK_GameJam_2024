class_name PickupManager
extends Node

var m_picked_element: PickupableNode
var m_owner: AvatarController

func init_manager(new_owner: Node2D) -> void:
	m_owner = new_owner
	m_owner.on_size_change.connect(m_scale_pickup)


func pick_up_element(new_element: Node2D) -> void:
	if m_picked_element:
		return
	m_picked_element = new_element as PickupableNode
	m_picked_element.disable_collisions()
	m_picked_element.m_default_scale = m_picked_element.scale

	match m_picked_element.required_size:
		AvatarController.Size.Large:
			m_picked_element.m_default_scale /= m_owner.large_scale.scale_multiplier
		AvatarController.Size.Small:
			m_picked_element.m_default_scale /= m_owner.small_scale.scale_multiplier

	Popups.set_popup_text(m_picked_element.m_popup_id, "[key:interact]: Drop")
	#print("picked up ", m_picked_element.name)
	#m_scale_pickup(m_owner.m_current_size, m_owner.m_attributes.scale_multiplier)

func has_picked_up_something() -> bool:
	return m_picked_element != null

func release_picked_up_element() -> void:
	if m_picked_element.m_can_placedown_flag:
		m_picked_element.enable_collisions()
		m_picked_element = null


func _process(_delta) -> void:
	if not m_picked_element:
		return
	m_picked_element.global_position = m_picked_element.get_global_mouse_position()

func m_scale_pickup(size_id: int, new_scale: float) -> void:
	if not m_picked_element:
		return

	# Block: 1 (1 * 1 = 1)
	# Me: 2 > 1
	m_picked_element.scale = m_picked_element.m_default_scale * new_scale  # (new_scale / m_owner.large_scale.scale_multiplier)
	m_picked_element.required_size = size_id as AvatarController.Size
	print("scaled ", m_picked_element.name, " with owner at ", size_id as AvatarController.Size, " (new scale: ", new_scale, ")")


# var cam3D = get_viewport().get_camera_3d()
# 	global_position = cam3D.unproject_position(p.global_position) - size / 2.0
# 	visible = not cam3D.is_position_behind(p.global_position)

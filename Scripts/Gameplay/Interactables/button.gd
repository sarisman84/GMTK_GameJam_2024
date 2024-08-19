class_name Button2D
extends Interactable

@export var required_size: AvatarController.Size
@export var target_door: Door2D
@export var is_toggleable: bool = false

var m_popup_id: int

func _ready() -> void:
	on_interact_enter.connect(m_show_popup)
	on_interact_exit.connect(m_hide_popup)
	on_interact.connect(m_body_entered)


func m_body_entered(_owner: AvatarController) -> void:
	if _owner.m_current_size != required_size:
		return
	target_door.open()
	m_hide_popup(_owner)


func m_hide_popup(_owner: AvatarController) -> void:
	if _owner.m_current_size != required_size:
		return
	Popups.disable_popup(m_popup_id)


func m_show_popup(_owner: AvatarController) -> void:
	if _owner.m_current_size != required_size or target_door.is_open():
		return
	m_popup_id = Popups.enable_popup_at(self, "[key:interact]: Open Door")

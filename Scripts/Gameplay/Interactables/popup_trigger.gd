extends Area2D
class_name PopupTrigger

@export var popup_anchor : Node2D
@export_multiline var popup_text : String
@export var trigger_once : bool

var m_trigger_flag : bool
var m_popup_id : int


func _ready() -> void:
	m_trigger_flag = false
	body_entered.connect(m_trigger_popup)
	body_exited.connect(m_disable_popup)


func m_trigger_popup(_body : Variant) -> void:
	if m_trigger_flag and trigger_once:
		return
	m_trigger_flag = true
	m_popup_id = Popups.enable_popup_at(popup_anchor,popup_text)

func m_disable_popup(_body : Variant) -> void:
	Popups.disable_popup(m_popup_id)

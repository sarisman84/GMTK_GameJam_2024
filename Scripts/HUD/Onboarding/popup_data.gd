class_name PopupData
extends Resource

var m_tooltip_instance : CanvasLayer
var m_target_anchor : Node2D

var m_label : RichTextLabel

var text : String:
	get:
		return m_label.text
	set(value):
		m_label.text = value

var position : Vector2:
	get:
		return m_tooltip_instance.offset
	set(value):
		m_tooltip_instance.offset = value


static func constructor(m_parent : Node, m_node_preset : PackedScene) -> PopupData:
	var m_ins = PopupData.new()
	m_ins.m_tooltip_instance = m_node_preset.instantiate()
	m_parent.add_child(m_ins.m_tooltip_instance)
	m_ins.m_label = m_ins.m_get_label(m_ins.m_tooltip_instance)
	return m_ins

func m_get_label(ins : Node) -> RichTextLabel:
	for child in ins.get_children():
		if child is RichTextLabel:
			return child
		else:
			var m_r = m_get_label(child)
			if m_r:
				return m_r
	return null

func show() -> void:
	m_tooltip_instance.show()

func hide() -> void:
	m_tooltip_instance.hide()

func is_visible() -> bool:
	return m_target_anchor and m_tooltip_instance.is_visible()

func reset() -> void:
	hide()
	m_target_anchor = null

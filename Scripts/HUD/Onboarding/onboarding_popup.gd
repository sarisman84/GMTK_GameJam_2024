extends CanvasLayer
class_name OnboardingPopup

@export var keybind_keywords: Array[BindKeyword]
@export var screen_position: Vector2
@onready var m_label: RichTextLabel = $anchor/text_entry

var m_target_anchor: Node2D
var m_owner: Node2D

func assign_new_owner(new_owner: Node2D) -> void:
	m_owner = new_owner

func enable_popup_at(target_anchor: Node2D, some_text: String) -> void:
	m_target_anchor = target_anchor
	m_label.text = m_parse_text(some_text)
	m_label.show()

func disable_popup() -> void:
	m_label.text = ""
	m_label.hide()

func _process(_delta: float) -> void:
	if m_label.is_visible_in_tree():
		var m_target_raw_pos = m_target_anchor.global_position
		var m_target_pos = get_viewport().canvas_transform.basis_xform(m_target_raw_pos)

		#var m_owner_raw_pos = m_owner.global_position
		var m_owner_pos = get_viewport().canvas_transform.get_origin() - (get_viewport().get_visible_rect().size / 2.0)

		offset = m_owner_pos + m_target_pos

func m_parse_text(text: String) -> String:
	var m_result: String
	var m_content_array = text.split(" ")
	var keybind_regex = RegEx.new()
	keybind_regex.compile("\\[key:[A-Za-z]+\\]")
	for word in m_content_array:
		var m_search_result = keybind_regex.search(word)
		if m_search_result:
			var m_key = m_search_result.get_string().replace("[key:", "").replace("]", "")
			var data = m_get_keyword(m_key)
			var start = "[img=%fx%f]" % [data.icon_size.x, data.icon_size.y]
			var end = "[/img] "
			m_result += start + data.bind_icon + end
		else:
			m_result += word + " "
	return m_result

func m_get_keyword(key: String) -> BindKeyword:
	for entry in keybind_keywords:
		if entry.keyword == key:
			return entry
	print("failed to find entry: ", key)
	return keybind_keywords[0]

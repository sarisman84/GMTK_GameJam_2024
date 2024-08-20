class_name PopupManager
extends Node


@export var center_text : bool
@export var keybind_keywords: Array[BindKeyword]
@export var screen_position: Vector2
@export_file var tooltip_preset : String
@export var max_tooltips_present : int = 10

@onready var m_tooltip_holder = $tooltip_holder

var m_tooltip_package : PackedScene



var m_spawned_tooltips : Array[PopupData]
var m_available_id : int = 0

var m_target_anchor: Node2D
var m_owner: Node2D

func _ready() -> void:
	m_tooltip_package = load(tooltip_preset)

	for i in range(max_tooltips_present):
		m_spawned_tooltips.append(PopupData.constructor(m_tooltip_holder,m_tooltip_package))
		m_spawned_tooltips[i].reset()


func assign_new_owner(new_owner: Node2D) -> void:
	m_owner = new_owner

func enable_popup_at(target_anchor: Node2D, some_text: String) -> int:
	var i = m_available_id
	m_available_id += 1

	m_spawned_tooltips[i].m_target_anchor = target_anchor
	m_spawned_tooltips[i].text = m_parse_text(some_text)
	m_spawned_tooltips[i].show()

	return i

func disable_popup(id : int) -> void:
	if id >= m_spawned_tooltips.size():
		return

	m_spawned_tooltips[id].hide()
	m_spawned_tooltips[id].m_target_anchor = null
	m_available_id -= 1
	m_available_id = max(m_available_id, 0)

func set_popup_text(id : int, some_text : String) -> void:
	m_spawned_tooltips[id].text = m_parse_text(some_text)

func _process(_delta: float) -> void:
	for i in range(m_spawned_tooltips.size()):
		var m_tooltip := m_spawned_tooltips[i]
		if m_tooltip.is_visible():
			var m_target_raw_pos = m_tooltip.m_target_anchor.global_position
			var m_target_pos = get_viewport().canvas_transform.basis_xform(m_target_raw_pos)
			var m_owner_pos = get_viewport().canvas_transform.get_origin() - (get_viewport().get_visible_rect().size / 2.0)
			m_tooltip.position = m_owner_pos + m_target_pos

func m_parse_text(text: String) -> String:
	var m_result: String
	if center_text:
		m_result = "[center]"
	var m_content_array = text.split(" ")
	var m_keybind_regex = RegEx.new()
	var m_new_line_regex = RegEx.new()
	m_keybind_regex.compile("\\[key:[A-Za-z]+\\]")
	m_new_line_regex.compile("\\/n")
	for word in m_content_array:
		var m_keybind_search_result = m_keybind_regex.search(word)
		var m_new_line_search_result = m_new_line_regex.search(word)
		if m_keybind_search_result:
			var m_key = m_keybind_search_result.get_string().replace("[key:", "").replace("]", "")
			var data = m_get_keyword(m_key)
			var start : String = ""
			if data.icon_size.x == 0 or data.icon_size.y == 0:
				start = "[img]"
			else:
				start = "[img=%fx%f]" % [data.icon_size.x, data.icon_size.y]
			var end = "[/img] "
			m_result += start + data.bind_icon + end
		elif m_new_line_search_result:
			var m_str = word.replace("/n", "")
			m_result += '\n' + m_str
		else:
			#print("cound't find anything in the word: ", word, ". Results: <keybind_search_result: ", m_keybind_search_result,">, <new_line_search_result: ", m_new_line_search_result, ">")
			m_result += word + " "
	if center_text:
		m_result += "[/center]"
	return m_result

func m_get_keyword(key: String) -> BindKeyword:
	for entry in keybind_keywords:
		if entry.keyword == key:
			return entry
	print("failed to find entry: ", key)
	return keybind_keywords[0]

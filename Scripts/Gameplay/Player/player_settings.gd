class_name PlayerSettings
extends Resource

@export_group("Default")
@export var speed : float = 300
@export var jump_height_in_px : float = 10.0
@export var small_size_max_health : int = 2
@export var regular_size_max_health : int = 6
@export var large_size_max_health : int = 12
@export var default_zoom : float = 8
@export_group("Attack")
@export var can_attack : bool = true
@export var attack_damage : float = 1
@export var attack_rate_in_seconds : float = 0.25
@export_group("Dash")
@export var dash_duration_in_seconds : float = 0.25
@export var dash_speed : float = 400
@export var dash_hover_duration_in_seconds : float = 3
@export var dash_count : int = 1
@export_group("Large")
@export var large_scale_settings : ScaleSettings
@export_group("Small")
@export var small_scale_settings : ScaleSettings


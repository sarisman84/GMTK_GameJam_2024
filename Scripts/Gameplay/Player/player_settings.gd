class_name PlayerSettings
extends Resource

@export_group("Default")
@export var speed : float = 300
@export var jump_height_in_px : float = 10.0
@export var max_health : int = 3
@export var default_zoom : float = 8
@export_group("Attack")
@export var can_attack : bool = true
@export var attack_damage : float = 1
@export var attack_rate_in_seconds : float = 0.25
@export_group("Large")
@export var large_scale_settings : ScaleSettings
@export_group("Small")
@export var small_scale_settings : ScaleSettings


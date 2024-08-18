class_name ScaleSettings
extends Resource

@export var scale_multiplier: float = 1
@export_group("Attack")
@export var override_attack: bool
@export var can_attack: bool
@export var attack_damage: float
@export var attack_rate_in_seconds: float = 0.25

@export_group("Jump")
@export var override_jump_height: bool
@export var jump_height: float

@export_group("Speed")
@export var override_speed: bool
@export var speed: float

@export_group("Gravity")
@export var override_gravity: bool
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("Dash")
@export var override_dash: bool
@export var can_dash: bool
@export var dash_count: int = 1
@export var dash_range_in_px: float = 100
@export var dash_duration_in_seconds: float = 0.25
@export var aim_duration_in_seconds: float = 2

@export_group("Camera Zoom")
@export var override_camera_zoom: bool
@export var camera_zoom: Vector2 = Vector2(1, 1)

@export_group("Sprite")
@export var override_sprite: bool
@export var sprite_scale : Vector2 = Vector2(1,1)

@export_group("Collision")
@export var override_collison: bool
@export var collision_scale : Vector2 = Vector2(1,1)

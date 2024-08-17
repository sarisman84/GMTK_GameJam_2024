class_name ScaleSettings
extends Resource

@export var scale_multiplier: float = 10
@export_group("Attack")
@export var override_attack: bool
@export var attack_damage: float
@export var attack_rate_in_seconds : float = 0.25
@export var can_attack: bool
@export_group("Jump")
@export var override_jump_height: bool
@export var jump_height: float
@export_group("Speed")
@export var override_speed: bool
@export var speed: float
@export_group("Gravity")
@export var override_gravity: bool
@export var gravity: float

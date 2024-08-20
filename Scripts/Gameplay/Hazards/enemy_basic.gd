extends CharacterBody2D

@export var m_max_health : int = 5
@export var m_health_regeneration_points : int = 1
@onready var m_health : HealthNode = $health
@onready var m_health_bar : ProgressBar = $health_bar
@onready var m_sprite : Sprite2D = $sprite

var m_speed : float = 10
var m_gravity : float = 14
var m_dir : float = 1.0

func _ready() -> void:
	m_health.set_max_health(m_max_health)
	m_health.on_damage_taken.connect(m_on_damage_taken)
	m_health.on_death.connect(m_on_hazard_death)
	m_health_bar.value = m_health.m_current_health

func m_on_hazard_death(_health_node : HealthNode) -> void:
	HealthRegenBar.update_points(m_health_regeneration_points)
	queue_free()

func m_on_damage_taken() -> void:
	m_health_bar.value = m_health.m_current_health - 1
	m_apply_damage_vfx()

func _physics_process(_delta):
	if not is_on_floor():
		velocity.y += m_gravity

	velocity.x = m_speed * m_dir
	move_and_slide()

	if is_on_wall():
		m_dir = -m_dir

func _on_area_2d_body_entered(body):
	if body.name == "player_avatar":
		body.get_node("health").apply_damage(1)


func m_apply_damage_vfx() -> void:
	var shader_code = """
	shader_type canvas_item;

	uniform float flicker_amount : hint_range(0.0, 1.0) = 0.0;

	void fragment() {
		vec4 tex_color = texture(TEXTURE, UV);
		COLOR = mix(tex_color, vec4(1.0, 0.0, 0.0, tex_color.a), flicker_amount);
	}
	"""
	pass

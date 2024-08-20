extends CharacterBody2D
class_name AvatarController

enum Size {Normal = 0, Small = -1, Large = 1}

@export_group("Settings")
@export var normal_scale: ScaleSettings
@export var small_scale: ScaleSettings
@export var large_scale: ScaleSettings
@export_group("Other")
@export var default_size: Size = Size.Normal
@export var sprites: Array[Texture2D]

@onready var m_camera: Camera2D = $camera
@onready var m_collider: CollisionShape2D = $shape
@onready var m_sprite: Sprite2D = $sprite
@onready var m_health: HealthNode = $health
@onready var m_attack: AttackNode = $attack
@onready var m_interact: InteractNode = $interact
@onready var m_pickup_manager: PickupManager = $pickup_manager
@onready var m_sfx_manager: SFXManager = $sfx_manager
@onready var m_ceiling_detector = $ceiling_detector
@onready var m_arrow = $arrow
#@onready var m_companion = $companion
@onready var m_animation: AnimatedSprite2D = $animation
@onready var m_small_animation: AnimationPlayer = $small_animation
#@onready var m_book_animation : AnimatedSprite2D = $book_animation
@onready var m_hud: CanvasLayer = $hud
@onready var m_book_anchor: Node2D = $shape/book_anchor
@onready var m_companion_book: Companion = %companion

#Signals
signal on_size_change(size_id, new_scale)
signal book_animation

#Default Child Node Settings
var m_default_col_scale: Vector2
var m_default_sprite_scale: Vector2
var m_default_arrow_scale: Vector2
var m_default_ceil_scale: float
var m_default_ceil_pos_y: float
var m_default_animation_scale: Vector2
var m_default_book_animation_scale: Vector2

#Temp Data
var m_current_gravity: float
var m_cur_dash_duration_in_seconds: float
var m_cur_dash_direction: Vector2
var m_cur_dash_hover_duration_in_seconds: float
var m_cur_dash_count: int
var m_current_size: int
var m_current_max_health: int

var m_dir: float

#Current Setting
var m_current_scale: ScaleSettings
var m_attributes: ScaleSettings
var m_next_scale: ScaleSettings


func _ready() -> void:
	m_arrow.hide()
	Popups.assign_new_owner(self)

	m_init_default_scales()
	reset_player()
	m_init_health()


	m_pickup_manager.init_manager(self)
	m_hud.update_max_health(m_attributes.max_health)
	m_hud.update_current_health(m_calculate_new_health_on_size_change(m_current_size))

	m_companion_book.on_book_attack_apex.connect(m_on_book_swing)


func m_test() -> void:
	var m_current_position = m_animation.frame
	if m_current_position in [4, 7, 13] and m_animation.visible:
		if is_on_floor():
			m_sfx_manager.play_footstep_sound(m_current_size)

func add_dash_charge():
	m_cur_dash_count += 1

func m_init_default_scales() -> void:
	m_default_col_scale = m_collider.scale
	m_default_sprite_scale = m_sprite.scale
	m_default_arrow_scale = m_arrow.scale
	m_default_animation_scale = m_animation.scale
	#m_default_book_animation_scale = m_book_animation.scale
	var m_sphere := m_ceiling_detector.shape as CircleShape2D
	m_default_ceil_scale = m_sphere.radius
	m_default_ceil_pos_y = m_ceiling_detector.position.y

func m_init_health() -> void:
	m_health.set_health_node_owner(self)
	m_health.set_max_health(m_attributes.max_health)
	m_health.on_death.connect(m_on_player_death)
	m_health.on_damage_taken.connect(m_hud_update_damage)
	m_health.on_heal.connect(m_hud_update_heal)

func m_hud_update_damage() -> void:
	m_hud.hud_take_damage()

func m_hud_update_heal() -> void:
	m_hud.hud_heal()

func m_on_player_death() -> void:
	var coords = get_node("/root/Global").latest_checkpoint[1]
	position = coords
	reset_player()
	pass

func reset_player() -> void:
	m_current_size = default_size
	m_apply_settings(m_current_size)
	m_attack.switch_face(1)
	m_health.set_max_health(m_attributes.max_health)
	m_health.reset_health()
	pass

func m_get_jump_velocity(target_height: float) -> float:
	return -sqrt(2 * target_height / m_attributes.gravity) * m_attributes.gravity

func m_calculate_new_health_on_size_change(type: int):
	# Default typing values
	var m_normal := 0
	var m_small := -1
	#var m_large := 1

	var m_current_health = m_health.m_current_health
	m_current_max_health = m_health.m_max_health
	var m_new_max_health

	if type == m_small:
		m_new_max_health = small_scale.max_health
	elif type == m_normal:
		m_new_max_health = normal_scale.max_health
	else:
		m_new_max_health = large_scale.max_health

	var m_new_health = clamp(floor((float(m_current_health) / m_current_max_health) * m_new_max_health), 1, m_new_max_health)
	return m_new_health

func m_change_sprite_on_size_change(type: int) -> void:
	m_sprite.texture = sprites[type + 1]
	var shader_code = """
	shader_type canvas_item;

	uniform float flicker_amount : hint_range(0.0, 1.0) = 0.0;

	void fragment() {
		vec4 tex_color = texture(TEXTURE, UV);
		COLOR = mix(tex_color, vec4(1.0, 1.0, 1.0, tex_color.a), flicker_amount);
	}
	"""

	var shader = Shader.new()
	shader.code = shader_code

	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader

	m_sprite.material = shader_material

	var flicker_duration = 0.5 # Flicker duration in seconds
	var flicker_rate = 0.05 # Flicker rate in seconds
	var elapsed_time = 0.0

	while elapsed_time < flicker_duration:
		shader_material.set("shader_param/flicker_amount", 1.0)
		await get_tree().create_timer(flicker_rate).timeout
		shader_material.set("shader_param/flicker_amount", 0.0)
		await get_tree().create_timer(flicker_rate).timeout
		elapsed_time += flicker_rate * 2

	shader_material.set("shader_param/flicker_amount", 0.0)

func m_apply_settings(type: int) -> void:

	# Default typing values
	var m_normal := 0
	var m_small := -1
	var m_large := 1
	var m_new_health = await m_calculate_new_health_on_size_change(type)
	m_health.set_current_health(m_new_health)

	#Change sprite
	if m_attributes != null: ## prevent sprite change on init
		m_change_sprite_on_size_change(type)


	match type:
		m_normal:
			m_current_scale = normal_scale
			m_next_scale = large_scale
			pass
		m_small:
			m_current_scale = small_scale
			m_next_scale = normal_scale
			pass
		m_large:
			m_current_scale = large_scale
			m_next_scale = large_scale
			pass

	#Apply new default scale to attack, health and interact hitboxes
	m_attack.scale_hitbox(m_current_scale.scale_multiplier)
	m_health.scale_hitbox(m_current_scale.scale_multiplier)
	m_interact.scale_hitbox(m_current_scale.scale_multiplier)

	#Calculate each attribute to scale with the player (unless overriden)
	m_attributes = m_get_scaled_attributes(m_current_scale)

	#Apply scaling to visual and functional elements
	m_collider.scale = m_attributes.collision_scale
	m_sprite.scale = m_attributes.sprite_scale
	m_camera.zoom = m_attributes.camera_zoom
	m_health.set_max_health(m_attributes.max_health)

	var tween
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(m_camera, "zoom", m_camera.zoom, 1)
	#tween.EASE_IN
	# ^^ Godot says this line has no effect


	var m_sphere = m_ceiling_detector.shape as CircleShape2D
	m_sphere.radius = m_default_ceil_scale * (m_next_scale.scale_multiplier * 0.15)

	var m_rect = m_collider.shape as RectangleShape2D

	position.y -= (m_rect.size.y * m_collider.scale.y) / 2.0

	var m_skin_width: float = m_sphere.radius
	m_ceiling_detector.position.y = m_default_ceil_pos_y - m_skin_width
	m_ceiling_detector.target_position.y = -(((m_rect.size.y * m_next_scale.scale_multiplier)) + m_skin_width)

	#Emit scale change event
	on_size_change.emit(type, m_current_scale.scale_multiplier)

	#Update HUD
	m_hud.update_max_health(m_attributes.max_health)
	m_hud.update_current_health(m_new_health)

	m_companion_book.change_scale(m_current_scale.scale_multiplier)

func m_get_default_setting() -> ScaleSettings:
	var m_normal := 0
	var m_small := -1
	var m_large := 1

	match default_size:
		m_normal:
			return normal_scale
		m_small:
			return small_scale
		m_large:
			return large_scale
	return normal_scale

func m_get_scaled_attributes(scale_setting: ScaleSettings) -> ScaleSettings:
	var m_result: ScaleSettings = ScaleSettings.new()

	if scale_setting.override_speed:
		m_result.speed = scale_setting.speed
	else:
		m_result.speed = m_get_default_setting().speed * scale_setting.scale_multiplier

	if scale_setting.override_attack:
		m_result.attack_damage = scale_setting.attack_damage
		m_result.attack_rate_in_seconds = scale_setting.attack_rate_in_seconds
		m_result.can_attack = scale_setting.can_attack
	else:
		m_result.attack_damage = m_get_default_setting().attack_damage
		m_result.attack_rate_in_seconds = m_get_default_setting().attack_rate_in_seconds
		m_result.can_attack = m_get_default_setting().can_attack

	if scale_setting.override_jump_height:
		m_result.jump_height = scale_setting.jump_height
	else:
		m_result.jump_height = m_get_default_setting().jump_height * scale_setting.scale_multiplier

	if scale_setting.override_gravity:
		m_result.gravity = scale_setting.gravity
	else:
		m_result.gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * scale_setting.scale_multiplier

	if scale_setting.override_dash:
		m_result.dash_duration_in_seconds = scale_setting.dash_duration_in_seconds
		m_result.dash_range_in_px = scale_setting.dash_range_in_px
		m_result.aim_duration_in_seconds = scale_setting.aim_duration_in_seconds
		m_result.dash_count = scale_setting.dash_count
	else:
		m_result.dash_duration_in_seconds = m_get_default_setting().dash_duration_in_seconds
		m_result.dash_range_in_px = m_get_default_setting().dash_range_in_px * scale_setting.scale_multiplier
		m_result.aim_duration_in_seconds = m_get_default_setting().aim_duration_in_seconds
		m_result.dash_count = m_get_default_setting().dash_count

	if scale_setting.override_camera_zoom:
		m_result.camera_zoom = scale_setting.camera_zoom
	else:
		m_result.camera_zoom = m_get_default_setting().camera_zoom * (1.0 / scale_setting.scale_multiplier)

	if scale_setting.override_sprite:
		var m_new_scale = m_default_sprite_scale * scale_setting.sprite_scale
		m_result.sprite_scale = m_new_scale
	else:
		m_result.sprite_scale = m_default_sprite_scale * scale_setting.scale_multiplier

	m_arrow.scale = m_default_arrow_scale * scale_setting.scale_multiplier
	m_animation.scale = m_default_animation_scale * scale_setting.scale_multiplier
	#m_book_animation.scale = m_default_book_animation_scale * scale_setting.scale_multiplier

	if scale_setting.override_collison:
		m_result.collision_scale = scale_setting.collision_scale
	else:
		m_result.collision_scale = m_default_col_scale * scale_setting.scale_multiplier

	if scale_setting.override_health:
		m_result.max_health = scale_setting.max_health
	else:
		m_result.max_health = m_get_default_setting().max_health * scale_setting.scale_multiplier
	return m_result

func m_handle_movement(delta: float) -> void:

	if not is_on_floor():
		velocity.y += m_attributes.gravity * delta

	#Apply jump height using velocity conversion
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = m_get_jump_velocity(m_attributes.jump_height)

	#Fetch horizontal input
	m_dir = Input.get_axis("move_left", "move_right")

	#Apply it
	if m_dir:
		m_sprite.flip_h = m_dir < 0
		m_animation.flip_h = m_dir < 0
		#m_book_animation.flip_h = dir < 0
		m_companion_book.flip_side(m_dir as int)
		#Animation Handler:
		if m_current_size >= 0: # If Normal or Big size
			m_sprite.hide()
			m_animation.show()
			m_animation.play(str(m_current_size) + "_walk")
		elif is_on_floor(): # Small size
			m_sprite.show()
			m_small_animation.play("walk")
		else:
			pass
			m_small_animation.stop()


		if abs(m_dir * m_attributes.speed) > abs(velocity.x):
			velocity.x = m_dir * m_attributes.speed
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.1)
		# Switch Attack and Interact Face Direction
		m_attack.switch_face(m_dir as int)
		m_interact.switch_face(m_dir as int)
		m_book_anchor.switch_face(m_dir)
	elif is_on_floor():
		#Animation Handler P2
		m_sprite.show()
		m_animation.hide()
		m_small_animation.stop()

		#LERP back to 0
		velocity.x = lerp(velocity.x, 0.0, 0.4)

func m_handle_hover(_delta: float) -> void:
	velocity = Vector2.ZERO
	var m_mouse_pos = get_global_mouse_position()
	var m_arrow_direction = m_mouse_pos - position
	var m_rotation = m_arrow_direction.angle()
	if abs(m_rotation) > PI / 2:
		m_sprite.flip_h = true
		m_animation.flip_h = true
	else:
		m_sprite.flip_h = false
		m_animation.flip_h = false

func m_handle_dash(_delta: float) -> void:
	velocity = m_cur_dash_direction * m_attributes.dash_range_in_px


func m_handle_dash_aim(_delta) -> void:
	if is_on_floor():
		m_cur_dash_count = m_attributes.dash_count
	m_cur_dash_duration_in_seconds -= _delta

	if m_can_aim_for_dash():
		m_cur_dash_hover_duration_in_seconds = m_attributes.aim_duration_in_seconds
		m_cur_dash_count -= 1
		m_arrow.show()
		m_animation.stop()
		m_small_animation.stop()

	if m_can_dash(_delta):
		var m_book_attack_val := 25.0
		var m_mouse_pos = get_global_mouse_position()
		m_cur_dash_direction = (m_mouse_pos - position).normalized()
		m_companion_book.attack_towards(global_position - (m_cur_dash_direction * m_book_attack_val * m_current_scale.scale_multiplier), m_cur_dash_direction, 1)
		m_arrow.hide()

func m_rotate_dash_arrow():
	var m_mouse_pos = get_global_mouse_position()
	var m_arrow_direction = m_mouse_pos - position
	m_arrow.rotation = m_arrow_direction.angle()

func m_can_aim_for_dash() -> bool:
	return Input.is_action_just_pressed("dash") and m_cur_dash_hover_duration_in_seconds <= 0 and m_cur_dash_count > 0 and m_current_size < Size.Large

func m_can_dash(delta: float) -> bool:
	if not m_companion_book.is_attacking():
		m_cur_dash_hover_duration_in_seconds -= delta
	return m_cur_dash_hover_duration_in_seconds > 0 and Input.is_action_just_released("dash")


func m_on_book_swing(msg: Variant) -> void:
	match msg:
		1:
			m_cur_dash_duration_in_seconds = m_attributes.dash_duration_in_seconds
			m_cur_dash_hover_duration_in_seconds = 0
			pass
		0:
			m_attack.attack_current_targets(m_attributes.attack_damage, m_attributes.attack_rate_in_seconds)
			pass
	pass

func _physics_process(delta: float) -> void:
	if m_cur_dash_hover_duration_in_seconds > 0:
		m_handle_hover(delta)
	elif m_cur_dash_duration_in_seconds > 0:

		m_handle_dash(delta)
	else:
		m_handle_movement(delta)
		m_arrow.hide()
	move_and_slide()

func _process(_delta: float) -> void:
	m_handle_dash_aim(_delta)
	m_rotate_dash_arrow()
	#Link up Scale Mechanic to input

	var m_old_size = m_current_size
	var m_ceil_test = m_ceiling_detector.is_colliding()
	if Input.is_action_just_pressed("enlarge") and not m_ceil_test:
		m_current_size += 1
	elif Input.is_action_just_pressed("shrink"):
		m_current_size -= 1

	m_current_size = clamp(m_current_size, -1, 1)
	if m_old_size != m_current_size:
		m_apply_settings(m_current_size)

	# Link up attacking and interactive to their respective systems
	if Input.is_action_just_pressed("attack") and m_attributes.can_attack:
		m_companion_book.attack(m_attack.get_child(0) as Node2D, 0)
	if m_pickup_manager.has_picked_up_something() and Input.is_action_just_pressed("interact"):
		m_pickup_manager.release_picked_up_element()
	elif Input.is_action_just_pressed("interact"):
		m_interact.try_to_interact()

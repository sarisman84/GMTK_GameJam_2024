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

#Signals
signal on_size_change(size_id, new_scale)

#Default Child Node Settings
var m_default_col_scale: Vector2
var m_default_sprite_scale: Vector2

#Temp Data
var m_current_gravity: float
var m_cur_dash_duration_in_seconds: float
var m_cur_dash_direction: Vector2
var m_cur_dash_hover_duration_in_seconds: float
var m_cur_dash_count: int
var m_current_size: int

#Current Setting
var m_current_scale: ScaleSettings
var m_attributes: ScaleSettings


func _ready() -> void:
	Popups.assign_new_owner(self)

	m_init_default_scales()
	reset_player()
	m_init_health()

	m_pickup_manager.init_manager(self)


func add_dash_charge():
	m_cur_dash_count += 1

func m_init_default_scales() -> void:
	m_default_col_scale = m_collider.scale
	m_default_sprite_scale = m_sprite.scale

func m_init_health() -> void:
	m_health.set_health_node_owner(self)
	m_health.set_max_health(m_attributes.max_health)
	m_health.on_death.connect(m_on_player_death)
	m_health.on_damage_taken.connect(m_hud_update)

func m_hud_update() -> void:
	pass
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

func m_apply_settings(type: int) -> void:
	# Default typing values
	var m_normal := 0
	var m_small := -1
	var m_large := 1

	#Change sprite
	m_sprite.texture = sprites[type + 1]

	match type:
		m_normal:
			m_current_scale = normal_scale
			pass
		m_small:
			m_current_scale = small_scale
			pass
		m_large:
			m_current_scale = large_scale
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


	#Emit scale change event
	on_size_change.emit(type, m_current_scale.scale_multiplier)

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
	var dir = Input.get_axis("move_left", "move_right")
	#Apply it
	if dir:
		m_sprite.flip_h = dir < 0
		if abs(dir * m_attributes.speed) > abs(velocity.x):
			velocity.x = dir * m_attributes.speed
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.1)
		# Switch Attack and Interact Face Direction
		m_attack.switch_face(dir)
		m_interact.switch_face(dir)
	else:
		#LERP back to 0
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		#velocity.x = move_toward(velocity.x, 0, (m_current_speed * m_current_scale_multiplier))
	# move_and_slide()

func m_handle_hover(_delta: float) -> void:
	velocity = Vector2.ZERO
	pass

func m_handle_dash(_delta: float) -> void:
	velocity = m_cur_dash_direction * m_attributes.dash_range_in_px
	pass

func m_handle_dash_aim(_delta) -> void:
	if is_on_floor():
		m_cur_dash_count = m_attributes.dash_count

	m_cur_dash_duration_in_seconds -= _delta
	m_cur_dash_duration_in_seconds = max(m_cur_dash_duration_in_seconds, 0)

	m_cur_dash_hover_duration_in_seconds -= _delta
	m_cur_dash_hover_duration_in_seconds = max(m_cur_dash_hover_duration_in_seconds, 0)

	if Input.is_action_just_pressed("dash") and m_cur_dash_hover_duration_in_seconds <= 0 and m_cur_dash_count > 0 and m_current_size < Size.Large:
		m_cur_dash_hover_duration_in_seconds = m_attributes.aim_duration_in_seconds
		m_cur_dash_count -= 1

	if m_cur_dash_hover_duration_in_seconds > 0 and Input.is_action_just_released("dash"):
		var m_mouse_pos = get_global_mouse_position()
		m_cur_dash_direction = (m_mouse_pos - position).normalized()
		m_cur_dash_duration_in_seconds = m_attributes.dash_duration_in_seconds
		m_cur_dash_hover_duration_in_seconds = 0


func _physics_process(delta: float) -> void:
	if m_cur_dash_hover_duration_in_seconds > 0:
		m_handle_hover(delta)
	elif m_cur_dash_duration_in_seconds > 0:
		m_handle_dash(delta)
	else:
		m_handle_movement(delta)
	move_and_slide()


func _process(_delta: float) -> void:

	m_handle_dash_aim(_delta)

	#Link up Scale Mechanic to input
	var m_old_size = m_current_size
	if Input.is_action_just_pressed("enlarge"):
		m_current_size += 1
	elif Input.is_action_just_pressed("shrink"):
		m_current_size -= 1

	m_current_size = clamp(m_current_size, -1, 1)
	if m_old_size != m_current_size:
		m_apply_settings(m_current_size)

	# Link up attacking and interactive to their respective systems
	if Input.is_action_pressed("attack") and m_attributes.can_attack:
		m_attack.attack_current_targets(m_attributes.attack_damage, m_attributes.attack_rate_in_seconds)
	if m_pickup_manager.has_picked_up_something() and Input.is_action_just_pressed("interact"):
		m_pickup_manager.release_picked_up_element()
	elif Input.is_action_just_pressed("interact"):
		m_interact.try_to_interact()

# REFERENCE CODE FROM GDSCRIPT

# func _physics_process(delta):
# 	# Add the m_default_gravity.
# 	if not is_on_floor():
# 		velocity.y += m_default_gravity * delta

# 	# Handle jump.
# 	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
# 		velocity.y = JUMP_VELOCITY

# 	# Get the input direction and handle the movement/deceleration.
# 	# As good practice, you should replace UI actions with custom gameplay actions.
# 	var direction = Input.get_axis("ui_left", "ui_right")
# 	if direction:
# 		velocity.x = direction * SPEED
# 	else:
# 		velocity.x = move_toward(velocity.x, 0, SPEED)

# 	move_and_slide()

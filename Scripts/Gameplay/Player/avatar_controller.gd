extends CharacterBody2D
class_name AvatarController

enum Size {Normal = 0, Small = -1, Large = 1}

@export_category("settings")
@export var player_settings: PlayerSettings
@export_category("other")
@export var default_size: Size = Size.Normal
@export var sprites: Array[Texture2D]

@onready var m_camera: Camera2D = $camera
@onready var m_collider: CollisionShape2D = $shape
@onready var m_sprite: Sprite2D = $sprite
@onready var m_health: HealthNode = $health
@onready var m_attack: AttackNode = $attack
@onready var m_interact: InteractNode = $interact
@onready var m_pickup_manager: PickupManager = $pickup_manager
@onready var m_sfx_manager: Node = $sfx_manager

#Signals
signal on_size_change(size_id, new_scale)

#Default Info
var m_default_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var m_default_col_scale: Vector2
var m_default_sprite_scale: Vector2

#Temp Data
var m_final_gravity: float
var m_cur_dash_duration_in_seconds: float
var m_cur_dash_direction: Vector2
var m_cur_dash_hover_duration_in_seconds: float
var m_cur_dash_count: int

# Current Scale Data
var m_current_size: int
var m_current_scale_multiplier: float

# Current Movement Data
var m_current_gravity: float
var m_current_speed: float
var m_current_jump_height: float

#Current Attack Data
var m_current_attack_damage: float
var m_current_attack_flag: bool
var m_current_attack_rate_in_seconds: float

func _ready() -> void:
	Onboarding.assign_new_owner(self)
	m_pickup_manager.init_manager(self)

	m_init_default_scales()
	m_init_health()
	reset_player()

func add_dash_charge():
	m_cur_dash_count += 1

func m_init_default_scales() -> void:
	m_default_col_scale = m_collider.scale
	m_default_sprite_scale = m_sprite.scale

func m_init_health() -> void:
	m_health.set_health_node_owner(self)
	m_health.set_max_health(player_settings.regular_size_max_health)
	m_health.reset_health()
	m_health.on_death.connect(m_on_player_death)


func m_on_player_death() -> void:
	var coords = get_node("/root/Global").latest_checkpoint[1]
	position = coords
	reset_player()
	pass

func reset_player() -> void:
	m_current_size = default_size
	m_apply_settings(m_current_size)
	m_attack.switch_face(1)
	m_health.reset_health()
	pass

func m_get_jump_velocity(target_height: float) -> float:
	return -sqrt(2 * target_height / m_current_gravity) * m_current_gravity

func m_calculate_new_health_on_size_change(type: int):
	# Default typing values
	var m_normal := 0
	var m_small := -1
	var m_large := 1
	
	var m_current_health = m_health.m_current_health
	var m_current_max_health = m_health.m_max_health
	var m_new_max_health
	
	if type == m_small:
		m_new_max_health = player_settings.small_size_max_health
	elif type == m_normal:
		m_new_max_health = player_settings.regular_size_max_health
	else:
		m_new_max_health = player_settings.large_size_max_health

	var m_new_health = clamp(floor((float(m_current_health) / m_current_max_health) * m_new_max_health), 1, m_new_max_health)
	
	return m_new_health

func m_apply_settings(type: int) -> void:
	# Default typing values
	var m_normal := 0
	var m_small := -1
	var m_large := 1
	
	var m_new_health = await m_calculate_new_health_on_size_change(type)
	m_health.set_current_health(m_new_health)

	#Change sprite
	m_sprite.texture = sprites[type + 1]

	# No changes if normal sized
	if type == m_normal:
		m_final_gravity = m_default_gravity
		m_current_scale_multiplier = 1.0
		m_current_speed = player_settings.speed
		m_current_jump_height = player_settings.jump_height_in_px
		m_current_attack_damage = player_settings.attack_damage
		m_current_attack_flag = player_settings.can_attack
		m_current_attack_rate_in_seconds = player_settings.attack_rate_in_seconds
		#Apply new default max health
		m_health.set_max_health(player_settings.regular_size_max_health)


	#TODO - Clean this mess up
	# Apply small scale settings if applicaple
	elif type == m_small:
		m_current_scale_multiplier = player_settings.small_scale_settings.scale_multiplier

		#Apply new default max health
		m_health.set_max_health(player_settings.small_size_max_health)
		
		# Try Applying Speed Info
		if player_settings.small_scale_settings.override_speed:
			m_current_speed = player_settings.small_scale_settings.speed

		# Try Applying Jump Height Info
		if player_settings.small_scale_settings.override_jump_height:
			m_current_jump_height = player_settings.small_scale_settings.jump_height

		# Try Applying Gravity Info
		if player_settings.small_scale_settings.override_gravity:
			m_final_gravity = player_settings.small_scale_settings.gravity

		# Try Applying Attack Stats
		if player_settings.small_scale_settings.override_attack:
			m_current_attack_damage = player_settings.small_scale_settings.attack_damage
			m_current_attack_flag = player_settings.small_scale_settings.can_attack
			m_current_attack_rate_in_seconds = player_settings.small_scale_settings.attack_rate_in_seconds

	# Apply large scale settings if applicaple
	elif type == m_large:
		m_current_scale_multiplier = player_settings.large_scale_settings.scale_multiplier
		
		#Apply new default max health
		m_health.set_max_health(player_settings.large_size_max_health)

		# Try Applying Speed Info
		if player_settings.large_scale_settings.override_speed:
			m_current_speed = player_settings.large_scale_settings.speed

		# Try Applying Jump Height Info
		if player_settings.large_scale_settings.override_jump_height:
			m_current_jump_height = player_settings.large_scale_settings.jump_height

		# Try Applying Gravity Info
		if player_settings.large_scale_settings.override_gravity:
			m_final_gravity = player_settings.large_scale_settings.gravity

		# Try Applying Attack Stats
		if player_settings.large_scale_settings.override_attack:
			m_current_attack_damage = player_settings.large_scale_settings.attack_damage
			m_current_attack_flag = player_settings.large_scale_settings.can_attack
			m_current_attack_rate_in_seconds = player_settings.large_scale_settings.attack_rate_in_seconds


	#TODO - Add tweaning to camera zoom, sprite and collider scaling!

	# Apply new default camera zoom level
	m_camera.zoom = Vector2.ONE * player_settings.default_zoom * (1.0 / m_current_scale_multiplier)

	#Apply new default collision size
	m_collider.scale = m_default_col_scale * m_current_scale_multiplier

	#Apply new default sprite size
	m_sprite.scale = m_default_sprite_scale * m_current_scale_multiplier

	#Apply new default gravity
	m_current_gravity = m_final_gravity * m_current_scale_multiplier

	#Apply new default scale to attack, health and interact hitboxes
	m_attack.scale_hitbox(m_current_scale_multiplier)
	m_health.scale_hitbox(m_current_scale_multiplier)
	m_interact.scale_hitbox(m_current_scale_multiplier)

	on_size_change.emit(m_current_size, m_current_scale_multiplier)

func m_handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += m_current_gravity * delta

	#Apply jump height using velocity conversion
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = m_get_jump_velocity(m_current_jump_height * m_current_scale_multiplier)

	#Fetch horizontal input
	var dir = Input.get_axis("move_left", "move_right")
	
	#Apply it
	if dir:
		m_sprite.flip_h = dir < 0
		m_sfx_manager.m_play_footstep_sound(m_current_size)
		if abs(dir * (m_current_speed * m_current_scale_multiplier)) > abs(velocity.x):
			velocity.x = dir * (m_current_speed * m_current_scale_multiplier)
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
	#if not is_on_floor():
		#velocity.y += (m_current_gravity / 12.0) * _delta

func m_handle_dash(_delta: float) -> void:
	# var x_dir = Input.get_axis("move_left", "move_right")
	# var y_dir = Input.get_axis("up", "down")
	# if x_dir == 0 && y_dir == 0:
	# 	x_dir = 1 if m_sprite.flip_h else -1
	# var vector = Vector2(x_dir, y_dir).normalized()
	# var speed = 400
	# velocity = vector * speed * m_current_scale_multiplier
	velocity = m_cur_dash_direction * player_settings.dash_speed * m_current_scale_multiplier
	pass

func m_handle_dash_aim(_delta) -> void:
	if is_on_floor():
		m_cur_dash_count = player_settings.dash_count

	m_cur_dash_duration_in_seconds -= _delta
	m_cur_dash_duration_in_seconds = max(m_cur_dash_duration_in_seconds, 0)

	m_cur_dash_hover_duration_in_seconds -= _delta
	m_cur_dash_hover_duration_in_seconds = max(m_cur_dash_hover_duration_in_seconds, 0)

	if Input.is_action_just_pressed("dash") and m_cur_dash_hover_duration_in_seconds <= 0 and m_cur_dash_count > 0 and m_current_size < Size.Large:
		m_cur_dash_hover_duration_in_seconds = player_settings.dash_hover_duration_in_seconds
		m_cur_dash_count -= 1

	if m_cur_dash_hover_duration_in_seconds > 0 and Input.is_action_just_released("dash"):
		var m_mouse_pos = get_global_mouse_position()
		m_cur_dash_direction = (m_mouse_pos - position).normalized()
		m_cur_dash_duration_in_seconds = player_settings.dash_duration_in_seconds
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
	if Input.is_action_pressed("attack") and m_current_attack_flag:
		m_attack.attack_current_targets(m_current_attack_damage, m_current_attack_rate_in_seconds)
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

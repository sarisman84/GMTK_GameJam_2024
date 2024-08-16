extends CharacterBody2D

enum Size {Normal = 0, Small = -1, Large = 1}

@export_category("settings")
@export var player_settings: PlayerSettings
@export_category("other")
@export var default_size: Size = Size.Normal

@onready var m_camera: Camera2D = $camera
@onready var m_collider: CollisionShape2D = $shape
@onready var m_sprite: Sprite2D = $sprite
@onready var m_health : HealthNode = $health

var m_hand_inventory
var m_default_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var m_final_gravity : float

var m_current_size: int
var m_current_offset: float
var m_current_gravity: float
var m_current_speed : float
var m_current_jump_height : float

func _ready() -> void:

	m_health.on_death.connect(m_on_player_death)
	m_current_size = default_size
	m_apply_settings(m_current_size)


func m_on_player_death() -> void:
	pass

func m_get_jump_velocity(target_height: float) -> float:
	return -sqrt(2 * target_height / m_current_gravity) * m_current_gravity

func m_apply_settings(type: int) -> void:
	# Default typing values
	var m_normal := 0
	var m_small := -1
	var m_large := 1

	# No changes if normal sized
	if type == m_normal:
		m_final_gravity = m_default_gravity
		m_current_offset = 1.0
		m_current_speed = player_settings.speed
		m_current_jump_height = player_settings.jump_height_in_px
	# Apply small scale settings if applicaple
	elif type == m_small:
		m_current_offset = player_settings.small_scale_settings.scale_multiplier

		if player_settings.small_scale_settings.override_speed:
			m_current_speed = player_settings.small_scale_settings.speed

		if player_settings.small_scale_settings.override_jump_height:
			m_current_jump_height = player_settings.small_scale_settings.jump_height

		if player_settings.small_scale_settings.override_gravity:
			m_final_gravity = player_settings.small_scale_settings.gravity

	# Apply large scale settings if applicaple
	elif type == m_large:
		m_current_offset = player_settings.large_scale_settings.scale_multiplier

		if player_settings.large_scale_settings.override_speed:
			m_current_speed = player_settings.large_scale_settings.speed

		if player_settings.large_scale_settings.override_jump_height:
			m_current_jump_height = player_settings.large_scale_settings.jump_height

		if player_settings.large_scale_settings.override_gravity:
			m_final_gravity = player_settings.large_scale_settings.gravity


	#TODO - Add tweaning to camera zoom, sprite and collider scaling!

	# Apply new default camera zoom level
	m_camera.zoom = Vector2.ONE * player_settings.default_zoom * (1.0 / m_current_offset)

	#Apply new default collision size
	m_collider.scale = Vector2.ONE * m_current_offset

	#Apply new default sprite size
	m_sprite.scale = Vector2.ONE * m_current_offset

	#Apply new default gravity
	m_current_gravity = m_final_gravity * m_current_offset

	#Apply new default max health
	m_health.set_max_health(player_settings.max_health * m_current_offset)

func handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y += m_current_gravity * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		var jv = m_get_jump_velocity(m_current_jump_height * m_current_offset)
		print(jv)
		velocity.y = jv

	var dir = Input.get_axis("move_left", "move_right")
	if dir:
		velocity.x = dir * (m_current_speed * m_current_offset)
	else:
		velocity.x = move_toward(velocity.x, 0, (m_current_speed * m_current_offset))

	move_and_slide()


func _physics_process(delta: float) -> void:
	handle_movement(delta)

func _process(_delta: float) -> void:
	var m_old_size = m_current_size
	if Input.is_action_just_pressed("enlarge"):
		m_current_size += 1
	elif Input.is_action_just_pressed("shrink"):
		m_current_size -= 1

	m_current_size = clamp(m_current_size, -1, 1)
	if m_old_size != m_current_size:
		m_apply_settings(m_current_size)


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

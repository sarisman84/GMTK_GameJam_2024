# # No changes if normal sized
	# if type == m_normal:
	# 	m_final_gravity = m_default_gravity
	# 	m_current_scale_multiplier = 1.0
	# 	m_current_speed = player_settings.speed
	# 	m_current_jump_height = player_settings.jump_height_in_px
	# 	m_current_attack_damage = player_settings.attack_damage
	# 	m_current_attack_flag = player_settings.can_attack
	# 	m_current_attack_rate_in_seconds = player_settings.attack_rate_in_seconds


	# #TODO - Clean this mess up
	# # Apply small scale settings if applicaple
	# elif type == m_small:
	# 	m_current_scale_multiplier = player_settings.small_scale_settings.scale_multiplier

	# 	# Try Applying Speed Info
	# 	if player_settings.small_scale_settings.override_speed:
	# 		m_current_speed = player_settings.small_scale_settings.speed

	# 	# Try Applying Jump Height Info
	# 	if player_settings.small_scale_settings.override_jump_height:
	# 		m_current_jump_height = player_settings.small_scale_settings.jump_height

	# 	# Try Applying Gravity Info
	# 	if player_settings.small_scale_settings.override_gravity:
	# 		m_final_gravity = player_settings.small_scale_settings.gravity

	# 	# Try Applying Attack Stats
	# 	if player_settings.small_scale_settings.override_attack:
	# 		m_current_attack_damage = player_settings.small_scale_settings.attack_damage
	# 		m_current_attack_flag = player_settings.small_scale_settings.can_attack
	# 		m_current_attack_rate_in_seconds = player_settings.small_scale_settings.attack_rate_in_seconds

	# # Apply large scale settings if applicaple
	# elif type == m_large:
	# 	m_current_scale_multiplier = player_settings.large_scale_settings.scale_multiplier

	# 	# Try Applying Speed Info
	# 	if player_settings.large_scale_settings.override_speed:
	# 		m_current_speed = player_settings.large_scale_settings.speed

	# 	# Try Applying Jump Height Info
	# 	if player_settings.large_scale_settings.override_jump_height:
	# 		m_current_jump_height = player_settings.large_scale_settings.jump_height

	# 	# Try Applying Gravity Info
	# 	if player_settings.large_scale_settings.override_gravity:
	# 		m_final_gravity = player_settings.large_scale_settings.gravity

	# 	# Try Applying Attack Stats
	# 	if player_settings.large_scale_settings.override_attack:
	# 		m_current_attack_damage = player_settings.large_scale_settings.attack_damage
	# 		m_current_attack_flag = player_settings.large_scale_settings.can_attack
	# 		m_current_attack_rate_in_seconds = player_settings.large_scale_settings.attack_rate_in_seconds


	# #TODO - Add tweaning to camera zoom, sprite and collider scaling!

	# # Apply new default camera zoom level
	# m_camera.zoom = Vector2.ONE * player_settings.default_zoom * (1.0 / m_current_scale_multiplier)

	# #Apply new default collision size
	# m_collider.scale = m_default_col_scale * m_current_scale_multiplier

	# #Apply new default sprite size
	# m_sprite.scale = m_default_sprite_scale * m_current_scale_multiplier

	# #Apply new default gravity
	# m_current_gravity = m_final_gravity * m_current_scale_multiplier

	# #Apply new default max health
	# m_health.set_max_health(player_settings.max_health * m_current_scale_multiplier)

	

	# on_size_change.emit(m_current_size, m_current_scale_multiplier)
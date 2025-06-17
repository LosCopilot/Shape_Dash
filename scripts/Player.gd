extends Area2D

signal player_hit

@export var normal_speed = 300
@export var dash_speed = 1200  # Aumentado para mayor impacto
@export var dash_duration = 0.35  # Duración aumentada
@export var dash_cooldown = 0.4   # Cooldown reducido
@export var acceleration = 15.0   # Para movimiento más fluido
@export var deceleration = 20.0   # Para frenado más suave

var current_speed = 0
var target_speed = 0
var velocity = Vector2.ZERO
var can_dash = true
var is_dashing = false
var last_movement_direction = Vector2.RIGHT

@onready var sprite = $Sprite
var dash_timer: Timer
var dash_cooldown_timer: Timer

func _ready():
	setup_timers()
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = 20
	get_parent().connect("game_started", _on_game_started)

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Actualizar dirección y velocidad objetivo
	if input_dir.length() > 0:
		last_movement_direction = input_dir.normalized()
		target_speed = normal_speed
	else:
		target_speed = 0
	
	# Suavizar aceleración/desaceleración
	if current_speed < target_speed:
		current_speed = min(current_speed + acceleration * delta * 60, target_speed)
	elif current_speed > target_speed:
		current_speed = max(current_speed - deceleration * delta * 60, target_speed)
	
	# Aplicar movimiento
	velocity = last_movement_direction * current_speed
	position += velocity * delta
	
	# Dash con Space
	if Input.is_action_just_pressed("dash") and can_dash and last_movement_direction != Vector2.ZERO:
		start_dash()

func setup_timers():
	dash_timer = Timer.new()
	dash_timer.name = "DashTimer"
	dash_timer.wait_time = dash_duration
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	add_child(dash_timer)
	
	dash_cooldown_timer = Timer.new()
	dash_cooldown_timer.name = "DashCooldownTimer"
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timer_timeout)
	add_child(dash_cooldown_timer)

func start_dash():
	if !can_dash: return
	
	can_dash = false
	is_dashing = true
	current_speed = dash_speed
	
	# Efecto visual mejorado
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.4, 0.6), 0.1)
	tween.parallel().tween_property(sprite, "modulate", Color(0.2, 0.2, 1.0, 0.8), 0.1)
	
	# Efecto de distorsión durante dash
	var distortion_tween = create_tween()
	distortion_tween.tween_property(sprite.material, "shader_param:distortion", 0.2, 0.1)
	
	dash_timer.start()
	dash_cooldown_timer.start()
	set_collision_mask_value(1, false)

func end_dash():
	is_dashing = false
	target_speed = normal_speed if Input.get_vector("move_left", "move_right", "move_up", "move_down").length() > 0 else 0
	
	# Restaurar efectos visuales suavemente
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.15)
	
	# Restaurar distorsión
	var distortion_tween = create_tween()
	distortion_tween.tween_property(sprite.material, "shader_param:distortion", 0.0, 0.15)
	
	set_collision_mask_value(1, true)

func _on_dash_timer_timeout():
	end_dash()

func _on_dash_cooldown_timer_timeout():
	can_dash = true

func _on_area_entered(area):
	if area.is_in_group("obstacle") and !is_dashing:
		player_hit.emit()

func _on_game_started():
	# Resetear estado al iniciar juego
	current_speed = 0
	target_speed = 0
	velocity = Vector2.ZERO
	can_dash = true
	is_dashing = false
	last_movement_direction = Vector2.RIGHT
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2.ONE

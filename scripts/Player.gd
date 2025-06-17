extends Area2D

signal player_hit

@export var normal_speed = 300
@export var dash_speed = 800
@export var dash_duration = 0.25  # Más tiempo de dash
@export var dash_cooldown = 0.5

var current_speed = normal_speed
var can_dash = true
var is_dashing = false
var last_movement_direction = Vector2.RIGHT  # Dirección por defecto

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
	
	# Actualizamos la última dirección de movimiento si hay input
	if input_dir.length() > 0:
		last_movement_direction = input_dir.normalized()
	
	# Movimiento continuo durante el dash
	position += last_movement_direction * current_speed * delta
	
	# Dash con Space
	if Input.is_action_just_pressed("dash") and can_dash:
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
	tween.tween_property(sprite, "scale", Vector2(1.3, 0.7), 0.05)
	tween.parallel().tween_property(sprite, "modulate", Color(0.3, 0.3, 1.0), 0.05)
	
	dash_timer.start()
	dash_cooldown_timer.start()
	set_collision_mask_value(1, false)

func end_dash():
	is_dashing = false
	current_speed = normal_speed
	set_collision_mask_value(1, true)
	
	# Restaurar efectos visuales
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _on_dash_timer_timeout():
	end_dash()

func _on_dash_cooldown_timer_timeout():
	can_dash = true

func _on_area_entered(area):
	if area.is_in_group("obstacle") and !is_dashing:
		player_hit.emit()

func _on_game_started():
	# Resetear estado al iniciar juego
	current_speed = normal_speed
	can_dash = true
	is_dashing = false
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2.ONE

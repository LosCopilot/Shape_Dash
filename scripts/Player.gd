extends Area2D

signal player_hit

@export var normal_speed = 300
@export var dash_speed = 1200
@export var dash_duration = 0.35
@export var dash_cooldown = 0.4
@export var acceleration = 15.0
@export var deceleration = 20.0

var current_speed = 0
var target_speed = 0
var velocity = Vector2.ZERO
var can_dash = true
var is_dashing = false
var last_movement_direction = Vector2.RIGHT

# Variables para límites (se configuran desde Main.gd)
var boundary_min_x = 0
var boundary_max_x = 1891  # Valor por defecto, será sobrescrito
var boundary_min_y = 0
var boundary_max_y = 1064  # Valor por defecto, será sobrescrito
const BOUNDARY_MARGIN = 50  # Margen de seguridad

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
	
	if input_dir.length() > 0:
		last_movement_direction = input_dir.normalized()
		target_speed = normal_speed
	else:
		target_speed = 0
	
	if current_speed < target_speed:
		current_speed = min(current_speed + acceleration * delta * 60, target_speed)
	elif current_speed > target_speed:
		current_speed = max(current_speed - deceleration * delta * 60, target_speed)
	
	velocity = last_movement_direction * current_speed
	position += velocity * delta
	
	if !is_dashing:
		clamp_player_position()
	else:
		check_dash_boundaries()
	
	if Input.is_action_just_pressed("dash") and can_dash and last_movement_direction != Vector2.ZERO:
		start_dash()

# Función para establecer límites desde Main.gd
func set_boundaries(min_x, max_x, min_y, max_y):
	boundary_min_x = min_x
	boundary_max_x = max_x
	boundary_min_y = min_y
	boundary_max_y = max_y

func clamp_player_position():
	position.x = clamp(position.x, boundary_min_x, boundary_max_x)
	position.y = clamp(position.y, boundary_min_y, boundary_max_y)

func check_dash_boundaries():
	if (position.x < boundary_min_x - 100 or position.x > boundary_max_x + 100 or
		position.y < boundary_min_y - 100 or position.y > boundary_max_y + 100):
		end_dash()
		position.x = clamp(position.x, boundary_min_x, boundary_max_x)
		position.y = clamp(position.y, boundary_min_y, boundary_max_y)

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
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.4, 0.6), 0.1)
	tween.parallel().tween_property(sprite, "modulate", Color(0.2, 0.2, 1.0, 0.8), 0.1)
	
	dash_timer.start()
	dash_cooldown_timer.start()
	set_collision_mask_value(1, false)

func end_dash():
	is_dashing = false
	target_speed = normal_speed if Input.get_vector("move_left", "move_right", "move_up", "move_down").length() > 0 else 0
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.15)
	
	set_collision_mask_value(1, true)
	clamp_player_position()

func _on_dash_timer_timeout():
	end_dash()

func _on_dash_cooldown_timer_timeout():
	can_dash = true

func _on_area_entered(area):
	if area.is_in_group("obstacle") and !is_dashing:
		player_hit.emit()

func _on_game_started():
	current_speed = 0
	target_speed = 0
	velocity = Vector2.ZERO
	can_dash = true
	is_dashing = false
	last_movement_direction = Vector2.RIGHT
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2.ONE
	if get_parent().has_method("get_player_start_position"):
		position = get_parent().get_player_start_position()

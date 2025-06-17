extends Node

# Señales
signal pattern_started(pattern_name: String)
signal pattern_ended

# Configuración
@export var patterns: Array[AttackPattern]
@export var cooldown: float = 2.0

var current_pattern: AttackPattern
var is_active: bool = false

@onready var timer = $Timer

func start_random_pattern():
	if patterns.is_empty() or is_active:
		return
	
	current_pattern = patterns.pick_random()
	is_active = true
	pattern_started.emit(current_pattern.name)
	
	timer.wait_time = current_pattern.spawn_interval
	timer.start()
	
	await get_tree().create_timer(current_pattern.duration).timeout
	stop_pattern()

func stop_pattern():
	timer.stop()
	is_active = false
	pattern_ended.emit()
	await get_tree().create_timer(cooldown).timeout
	start_random_pattern()

func _on_timer_timeout():
	if !current_pattern: return
	
	match current_pattern.name:
		"Circle":
			spawn_circle_pattern()
		"Spiral":
			spawn_spiral_pattern()
		_:
			spawn_default_pattern()

# Patrones específicos
func spawn_circle_pattern():
	var viewport = get_viewport().get_visible_rect()
	var center = viewport.size / 2
	var radius = 300
	var angle = randf() * TAU
	
	var pos = center + Vector2(cos(angle), sin(angle)) * radius
	var dir = (center - pos).orthogonal().normalized()
	
	current_pattern.spawn_obstacle(self, pos, dir)

func spawn_spiral_pattern():
	var viewport = get_viewport().get_visible_rect()
	var center = viewport.size / 2
	var t = randf()
	var revolutions = 2
	var angle = TAU * revolutions * t
	var radius = lerp(100, 400, t)
	
	var pos = center + Vector2(cos(angle), sin(angle)) * radius
	var dir = Vector2(-sin(angle), cos(angle))
	
	current_pattern.spawn_obstacle(self, pos, dir)

func spawn_default_pattern():
	var viewport = get_viewport().get_visible_rect()
	var pos = Vector2(
		randf_range(0, viewport.size.x),
		randf_range(0, viewport.size.y)
	)
	var dir = Vector2.RIGHT.rotated(randf_range(-PI, PI))
	
	current_pattern.spawn_obstacle(self, pos, dir)

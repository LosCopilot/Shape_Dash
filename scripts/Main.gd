extends Node2D

# Preloads
var player_scene = preload("res://scenes/Player.tscn")
var obstacle_scene = preload("res://scenes/Obstacle.tscn")
var ui_scene = preload("res://scenes/UI.tscn")

# Variables
var score = 0
var is_game_over = false
var game_speed = 200

func _ready():
	spawn_player()
	spawn_ui()
	$ObstacleTimer.start()

func spawn_player():
	var player = player_scene.instantiate()
	player.position = Vector2(400, 300)
	add_child(player)
	player.player_hit.connect(game_over)

func spawn_ui():
	var ui = ui_scene.instantiate()
	add_child(ui)
	ui.name = "UI"  # Asigna nombre explícito

func _on_obstacle_timer_timeout():
	if !is_game_over:
		var obstacle = obstacle_scene.instantiate()
		add_child(obstacle)
		obstacle.setup(get_random_edge_position(), game_speed)
		score += 1
		get_node("UI").update_score(score)  # Referencia explícita

func get_random_edge_position():
	# Implementación completa de la función
	var viewport_size = get_viewport_rect().size
	var side = randi() % 4
	
	match side:
		0: # Arriba
			return Vector2(randf_range(50, viewport_size.x - 50), -50)
		1: # Derecha
			return Vector2(viewport_size.x + 50, randf_range(50, viewport_size.y - 50))
		2: # Abajo
			return Vector2(randf_range(50, viewport_size.x - 50), viewport_size.y + 50)
		3: # Izquierda
			return Vector2(-50, randf_range(50, viewport_size.y - 50))

func game_over():
	is_game_over = true
	$ObstacleTimer.stop()
	show_game_over_text()

func show_game_over_text():
	var label = Label.new()
	label.text = "GAME OVER\nScore: %d" % score
	# Configuración de estilo
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(get_viewport_rect().size.x/2 - 100, get_viewport_rect().size.y/2 - 50)
	label.size = Vector2(200, 100)
	add_child(label)
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

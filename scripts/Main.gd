extends Node2D

# Preloads
var player_scene = preload("res://scenes/Player.tscn")
var obstacle_scene = preload("res://scenes/Obstacle.tscn")
var ui_scene = preload("res://scenes/UI.tscn")

# Configuración del escenario
const GAME_WIDTH = 1891
const GAME_HEIGHT = 1064

# Variables
var score = 0
var is_game_over = false
var game_speed = 200

func _ready():
	# Configura el tamaño del viewport (solución para Godot 4)
	get_tree().root.content_scale_size = Vector2(GAME_WIDTH, GAME_HEIGHT)
	get_viewport().size = Vector2i(GAME_WIDTH, GAME_HEIGHT)  # Alternativa para tamaño de ventana
	
	spawn_player()
	spawn_ui()
	$ObstacleTimer.start()

func spawn_player():
	var player = player_scene.instantiate()
	# Usamos float para evitar divisiones enteras
	player.position = Vector2(float(GAME_WIDTH) / 2.0, float(GAME_HEIGHT) / 2.0)  # Centro exacto
	add_child(player)
	player.player_hit.connect(game_over)

func spawn_ui():
	var ui = ui_scene.instantiate()
	add_child(ui)
	ui.name = "UI"

func _on_obstacle_timer_timeout():
	if !is_game_over:
		var obstacle = obstacle_scene.instantiate()
		add_child(obstacle)
		obstacle.setup(get_random_edge_position(), game_speed)
		score += 1
		get_node("UI").update_score(score)

func get_random_edge_position():
	var side = randi() % 4
	
	match side:
		0: # Arriba
			return Vector2(randf_range(50, GAME_WIDTH - 50), -50)
		1: # Derecha
			return Vector2(GAME_WIDTH + 50, randf_range(50, GAME_HEIGHT - 50))
		2: # Abajo
			return Vector2(randf_range(50, GAME_WIDTH - 50), GAME_HEIGHT + 50)
		3: # Izquierda
			return Vector2(-50, randf_range(50, GAME_HEIGHT - 50))

func game_over():
	is_game_over = true
	$ObstacleTimer.stop()
	show_game_over_text()

func show_game_over_text():
	var label = Label.new()
	label.text = "GAME OVER\nScore: %d" % score
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Usamos float para posicionamiento preciso
	label.position = Vector2(float(GAME_WIDTH) / 2.0 - 100, float(GAME_HEIGHT) / 2.0 - 50)
	label.size = Vector2(200, 100)
	
	add_child(label)
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

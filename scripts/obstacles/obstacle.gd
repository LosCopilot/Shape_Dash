extends Area2D

# Configuración
@export var base_speed: float = 200
@export var rotation_speed: float = 2.0
@export var lifetime: float = 10.0

# Variables
var direction: Vector2 = Vector2.ZERO
var current_speed: float = 0
var age: float = 0

@onready var sprite = $Sprite2D

func _ready():
	setup_obstacle()
	setup_material()

func setup_obstacle():
	# Configuración visual aleatoria
	var hue = randf()
	sprite.modulate = Color.from_hsv(hue, 0.9, 0.9)
	sprite.rotation = randf_range(0, TAU)
	
	# Colisión dinámica
	var shape = RectangleShape2D.new()
	shape.size = Vector2(randf_range(30, 60), randf_range(30, 60))
	$CollisionShape2D.shape = shape

func setup_material():
	var material = ShaderMaterial.new()
	material.shader = load("res://shaders/obstacle_outline.gdshader")
	sprite.material = material

func initialize(pos: Vector2, dir: Vector2, speed: float):
	position = pos
	direction = dir.normalized()
	current_speed = speed

func _process(delta):
	position += direction * current_speed * delta
	sprite.rotation += rotation_speed * delta
	
	age += delta
	if age > lifetime:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()

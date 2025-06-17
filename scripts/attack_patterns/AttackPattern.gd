class_name AttackPattern
extends Resource

@export var name: String = "Basic"
@export var obstacle_scene: PackedScene
@export var speed: float = 200
@export var duration: float = 3.0
@export var spawn_interval: float = 0.15
@export var movement_curve: Curve

# Función para instanciar obstáculos
func spawn_obstacle(parent: Node, pos: Vector2, dir: Vector2):
	var obstacle = obstacle_scene.instantiate()
	obstacle.initialize(pos, dir, speed * movement_curve.sample(randf()))
	parent.add_child(obstacle)
	return obstacle

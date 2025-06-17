extends Area2D

@export var speed = 200
var direction = Vector2.ZERO

func setup(pos: Vector2, spd: float):
	position = pos
	speed = spd
	direction = -pos.normalized()
	modulate = Color(randf(), randf(), randf())
	
	# Animación de aparición
	scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)

func _process(delta):
	position += direction * speed * delta
	rotation += delta * 2
	
	if is_out_of_screen():
		queue_free()

func is_out_of_screen():
	# Lógica para verificar si está fuera de pantalla
	var viewport_size = get_viewport_rect().size
	return (
		position.x < -100 or 
		position.x > viewport_size.x + 100 or
		position.y < -100 or 
		position.y > viewport_size.y + 100
	)

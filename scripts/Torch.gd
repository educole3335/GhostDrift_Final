extends Node2D

var t: float = 0.0

func _ready():
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("torch")

func _process(dt: float):
	t += dt
	if has_node("PointLight2D"):
		$PointLight2D.energy = 0.9 + sin(t * 3.5) * 0.35

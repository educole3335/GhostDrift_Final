extends Node2D

@export var amplitude: float = 120.0
@export var speed: float = 1.0

var origin = Vector2.ZERO
var t = 0.0

func _ready():
    origin = position
    set_process(true)

func _process(dt: float) -> void:
    t += dt * speed
    position.x = origin.x + sin(t) * amplitude

extends AnimatableBody2D

@export var distance: float    = 120.0
@export var speed: float       = 60.0
@export var horizontal: bool   = true

var origin: Vector2
var t: float = 0.0

func _ready():
	origin = global_position

func _physics_process(dt: float):
	t += dt * speed / distance
	var offset = sin(t) * distance
	global_position = origin + (Vector2(offset, 0.0) if horizontal else Vector2(0.0, offset))

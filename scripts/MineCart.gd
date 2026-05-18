extends AnimatableBody2D

@export var rail_length: float = 300.0
@export var cart_speed: float  = 80.0

var origin: Vector2
var t: float = 0.0

func _ready():
	origin = global_position

func _physics_process(dt: float):
	t += dt * cart_speed / rail_length
	global_position.x = origin.x + sin(t) * rail_length

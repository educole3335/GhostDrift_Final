extends Area2D

@export var strength: float = 220.0
@export var direction: Vector2 = Vector2.RIGHT

func _ready():
	monitoring = true
	set_physics_process(true)

func _physics_process(dt: float) -> void:
	for b in get_overlapping_bodies():
		if b and b.is_in_group("player"):
			var v = b.get("velocity")
			if v != null:
				v += direction.normalized() * strength * dt
				b.set("velocity", v)

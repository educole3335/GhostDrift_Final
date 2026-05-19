extends Area2D

@export var speed: float = 420.0
@export var lifetime: float = 4.0

var dir = Vector2.LEFT

func _ready():
    set_physics_process(true)
    await get_tree().create_timer(lifetime).timeout
    if is_instance_valid(self ):
        queue_free()

func _physics_process(dt: float) -> void:
    position += dir * speed * dt
    for b in get_overlapping_bodies():
        if b.is_in_group("player"):
            if b.has_method("take_damage"):
                b.take_damage(false, global_position, "projectile")
            queue_free()
            return

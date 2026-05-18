extends AnimatableBody2D

var triggered: bool = false
var fall_t: float   = 0.0

func _ready():
	add_to_group("platform")

func trigger():
	triggered = true

func _physics_process(dt: float):
	if not triggered:
		return
	fall_t += dt
	if fall_t > 0.5:
		global_position.y += 280.0 * dt
		modulate.a         = max(0.0, modulate.a - dt * 1.5)
		if modulate.a <= 0.0:
			queue_free()

# Detect player standing on this platform
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		trigger()

extends Area2D

@export var bounce_strength: float = 1.4

func _ready():
	monitoring = true
	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if not is_instance_valid(body):
		return
	if body.is_in_group("player"):
		var v = body.get("velocity")
		if v != null:
			v.y = -520.0 * bounce_strength
			body.set("velocity", v)
		AudioMgr.jump()

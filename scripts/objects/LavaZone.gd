extends Area2D

@export var damage_per_second: float = 1.0
@export var size: Vector2 = Vector2(200, 80)

var overlapping = []
var _dmg_acc: float = 0.0

func _ready():
	for c in get_children():
		if c is CollisionShape2D and c.shape is RectangleShape2D:
			c.shape.size = size
			break
	monitoring = true
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	set_physics_process(true)

func _on_enter(body: Node) -> void:
	if body and body.is_in_group("player"):
		overlapping.append(body)

func _on_exit(body: Node) -> void:
	overlapping.erase(body)

func _physics_process(dt: float) -> void:
	if overlapping.is_empty():
		return
	_dmg_acc += dt
	var interval = 1.0 / max(0.1, damage_per_second)
	if _dmg_acc >= interval:
		_dmg_acc = 0.0
		for b in overlapping:
			if is_instance_valid(b) and b.has_method("take_damage"):
				b.take_damage()

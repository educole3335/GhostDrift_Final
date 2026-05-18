extends Area2D

@export var blast_radius: float = 120.0
@export var damage: int = 2

var _exploded: bool = false

func _ready():
	monitoring = true
	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if not _exploded and (body.is_in_group("player") or body.is_in_group("enemy")):
		_explode()

func _explode():
	_exploded = true
	AudioMgr.explosion()
	var targets = get_tree().get_nodes_in_group("player") + get_tree().get_nodes_in_group("enemy")
	for b in targets:
		if is_instance_valid(b) and b.has_method("take_damage"):
			if global_position.distance_to(b.global_position) <= blast_radius:
				b.take_damage()
	queue_free()

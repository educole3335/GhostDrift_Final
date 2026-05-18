extends Area2D

func _ready():
	add_to_group("collectible")
	monitoring = true
	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if not is_instance_valid(body):
		return
	if body.is_in_group("player"):
		Global.add_score(50)
		AudioMgr.crystal_sfx()
		queue_free()

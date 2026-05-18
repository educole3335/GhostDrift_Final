extends Area2D

@export var key_id: String = "default"

func _ready():
	monitoring = true
	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if body.is_in_group("player"):
		Global.give_key(key_id)
		AudioMgr.crystal_sfx()
		queue_free()

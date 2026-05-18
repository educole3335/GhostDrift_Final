extends Area2D

@export var combo_level: int = 1

func _ready():
	monitoring = true
	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if body.is_in_group("player"):
		Global.upgrade_combo(combo_level)
		AudioMgr.pickup()
		queue_free()

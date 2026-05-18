extends Area2D

func _ready():
	monitoring = true
	body_entered.connect(_on_body)

func _on_body(body: Node) -> void:
	if body.is_in_group("player"):
		Global.give_dash(true)
		AudioMgr.pickup()
		queue_free()

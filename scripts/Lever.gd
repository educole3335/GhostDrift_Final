extends Area2D

var activated: bool = false

func _ready():
	body_entered.connect(_on_body)

func _on_body(body: Node2D):
	if activated or not body.is_in_group("player"):
		return
	activated = true
	AudioMgr.lever_sfx()
	# Visual feedback
	if has_node("VIS"):
		$VIS.modulate = Color(0.4, 1.0, 0.4)
	# Notify parent level — the level script handles door opening
	emit_signal("lever_pulled")

	# Auto-open nearest door in same scene (within 800 px)
	var closest = null
	var bestd = 1e9
	for d in get_tree().get_nodes_in_group("door"):
		if not is_instance_valid(d):
			continue
		if not d.has_method("open"):
			continue
		var dpos = d.global_position
		var dist = dpos.distance_to(global_position)
		if dist < bestd:
			bestd = dist
			closest = d
	if closest and bestd <= 800.0:
		closest.open()

signal lever_pulled

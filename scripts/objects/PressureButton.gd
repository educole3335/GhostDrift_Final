extends Area2D

@export var linked_group: String = "door"

var pressed = false

func _ready():
	monitoring = true
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body.is_in_group("player") and not pressed:
		pressed = true
		_activate()

func _on_exit(body: Node) -> void:
	if body.is_in_group("player") and pressed:
		pressed = false

func _activate():
	AudioMgr.lever_sfx()
	for d in get_tree().get_nodes_in_group(linked_group):
		if d.has_method("open"):
			d.open()

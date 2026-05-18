extends Area2D

@export var crystal_type: String = "purple"

var bob_t: float     = 0.0
var start_y: float
var collected: bool  = false

@onready var anim: AnimatedSprite2D = $AS

func _ready():
	add_to_group("crystal")
	start_y = global_position.y
	body_entered.connect(_on_body)
	if anim:
		anim.play("crystal_" + crystal_type)
	# Set light color
	if has_node("PL"):
		var lc = {
			"purple": Color(0.7, 0.3, 1.0),
			"blue":   Color(0.3, 0.7, 1.0),
			"orange": Color(1.0, 0.5, 0.1),
			"green":  Color(0.3, 1.0, 0.3),
			"red":    Color(1.0, 0.2, 0.2)
		}
		$PL.color = lc.get(crystal_type, Color(1, 1, 1))

func _process(dt: float):
	if collected:
		return
	bob_t            += dt
	global_position.y = start_y + sin(bob_t * 2.8) * 6.0
	if has_node("PL"):
		$PL.energy = 0.8 + sin(bob_t * 4.0) * 0.3

func _on_body(body: Node2D):
	if collected or not body.is_in_group("player"):
		return
	collected = true
	# Safely disable collision shape (name may be 'CollisionShape2D' or 'CS')
	var cs = get_node_or_null("CollisionShape2D")
	if cs == null:
		cs = get_node_or_null("CS")
	if cs:
		cs.set_deferred("disabled", true)
	else:
		for child in get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)
				break
	if anim:
		anim.visible = false
	if has_node("PL"):
		$PL.visible = false
	body.pick_crystal()
	queue_free()

extends Node2D
var is_open: bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body: CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready():
	add_to_group("door")

func open():
	if is_open:
		return
	is_open = true
	if anim:
		anim.play("door_open")
	if body:
		body.set_deferred("disabled", true)

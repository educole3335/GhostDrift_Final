extends Node2D

@export var shoot_interval: float = 2.0

var _t: float = 0.0

func _ready():
	add_to_group("enemy")
	_t = randf() * shoot_interval
	set_process(true)

func _process(dt: float) -> void:
	_t -= dt
	if _t <= 0.0:
		_shoot()
		_t = shoot_interval

func _shoot():
	var sc = load("res://scripts/objects/ProyectilShadow.gd")
	if not sc:
		return
	var proj = Area2D.new()
	proj.set_script(sc)
	proj.global_position = global_position
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		proj.dir = (players[0].global_position - global_position).normalized()
	else:
		proj.dir = Vector2.LEFT
	var cs = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 8.0
	cs.shape = shape
	proj.add_child(cs)
	get_tree().current_scene.add_child(proj)

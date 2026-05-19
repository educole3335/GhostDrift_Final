extends Node2D

@export var speed: float = 80.0
@export var damage_range: float = 40.0

var _damage_cd: float = 0.0
var _dead: bool = false

func _ready():
	add_to_group("enemy")
	set_process(true)

func _process(dt: float) -> void:
	if _dead:
		return
	_damage_cd -= dt
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var player = players[0]
	var diff = player.global_position - global_position
	if diff.length_squared() > 4.0:
		global_position += diff.normalized() * speed * dt
	if _damage_cd <= 0.0 and diff.length() < damage_range:
		if player.has_method("take_damage"):
			player.take_damage(false, global_position, "specter")
			_damage_cd = 1.5

func take_hit(_from: Vector2) -> bool:
	_dead = true
	AudioMgr.enemy_die()
	queue_free()
	return true

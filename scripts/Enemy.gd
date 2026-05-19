extends CharacterBody2D

@export var max_hp: int = 1
@export var spd: float = 68.0
@export var patrol_range: float = 150.0
@export var attack_range: float = 44.0
@export var is_boss: bool = false

var hp: int
var dead: bool = false
var death_t: float = 0.0
var patrol_origin: Vector2
var patrol_dir: int = 1
var atk_cd: float = 0.0
var hit_flash: float = 0.0
var player: Node2D = null
var facing_right: bool = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("enemy")
	hp = max_hp
	patrol_origin = global_position
	# Connect detect area if present
	if has_node("DetectArea"):
		var da = $DetectArea
		if not da.body_entered.is_connected(_on_detect_enter):
			da.body_entered.connect(_on_detect_enter)
		if not da.body_exited.is_connected(_on_detect_exit):
			da.body_exited.connect(_on_detect_exit)

func _physics_process(dt: float):
	if dead:
		death_t += dt
		anim.modulate.a = max(0.0, 1.0 - death_t / 0.9)
		if death_t > 1.1:
			queue_free()
		return

	atk_cd -= dt
	# Hit flash
	if hit_flash > 0.0:
		hit_flash -= dt
		anim.modulate = Color(1.5, 0.3, 0.3) if hit_flash > 0.0 else Color.WHITE
	else:
		anim.modulate = Color.WHITE

	# Gravity
	if not is_on_floor():
		velocity.y += 950.0 * dt
	else:
		velocity.y = 0.0

	# AI
	if player and is_instance_valid(player):
		_chase()
	else:
		_patrol()

	anim.flip_h = not facing_right
	anim.speed_scale = 0.85 if is_boss else 0.95
	anim.play("enemy_walk" if abs(velocity.x) > 10.0 else "enemy_idle")
	move_and_slide()

	# Check physical contact collisions to apply damage only on contact
	_check_contact_damage()

	# Optional Area2D child named "ContactArea" can explicitly report overlaps
	if has_node("ContactArea"):
		var ca = $ContactArea
		if ca and ca.get_overlapping_bodies().size() > 0 and atk_cd <= 0.0:
			for body in ca.get_overlapping_bodies():
				if is_instance_valid(body) and body.is_in_group("player") and body.has_method("take_damage"):
					body.take_damage(false, global_position)
					atk_cd = 1.4 if is_boss else 2.2
					break

func _patrol():
	velocity.x = patrol_dir * spd
	facing_right = patrol_dir > 0
	if abs(global_position.x - patrol_origin.x) > patrol_range:
		patrol_dir *= -1

func _chase():
	var diff = player.global_position.x - global_position.x
	facing_right = diff > 0.0
	if abs(diff) > attack_range:
		velocity.x = sign(diff) * spd * (1.5 if is_boss else 1.15)
	else:
		velocity.x = 0.0
		# Stop and wait for physical contact to apply damage (handled in _check_contact_damage)

func take_hit(from: Vector2):
	if dead:
		return false
	# brief invulnerability window (prevents multiple hits in same hit flash)
	if hit_flash > 0.0:
		return false
	hp -= 1
	hit_flash = 0.22
	AudioMgr.enemy_hit()
	velocity.x = sign(global_position.x - from.x) * 320.0
	velocity.y = -180.0
	if hp <= 0:
		_die()
		return true
	return false

func _die():
	dead = true
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	anim.play("enemy_death")
	AudioMgr.enemy_die()
	# Register kill centrally here so all deaths count (guarded by `dead` flag)
	if Engine.is_editor_hint() == false:
		if Global:
			Global.kill_enemy()

func _on_detect_enter(body: Node2D):
	if body.is_in_group("player"):
		player = body

func _on_detect_exit(body: Node2D):
	if body.is_in_group("player"):
		player = null

func _check_contact_damage():
	if atk_cd > 0.0:
		return
	var sc = get_slide_collision_count()
	for i in range(sc):
		var col = get_slide_collision(i)
		if not col:
			continue
		var collider = col.get_collider()
		if collider and collider.is_in_group("player") and is_instance_valid(collider):
			if collider.has_method("take_damage"):
				collider.take_damage(false, global_position)
				atk_cd = 1.4 if is_boss else 2.2
				return

extends CharacterBody2D
signal lives_changed
const WALK_SPEED = 200.0
const RUN_SPEED = 340.0
const JUMP_VEL = -520.0
const GRAVITY = 950.0
const MAX_FALL = 1100.0
const COYOTE_T = 0.12
const JUMP_BUF_T = 0.10
const SHADOW_DRAIN = 22.0
const SHADOW_REGEN = 18.0
const ATTACK_OFFSET = 46.0
const ATTACK_SIZE = Vector2(74.0, 44.0)
const ATTACK_ACTIVE_T = 0.20
const ATTACK_COOLDOWN_T = 0.28
const GROUND_ACCEL = 2200.0
const AIR_ACCEL = 1500.0
const GROUND_FRICTION = 2800.0
const AIR_FRICTION = 900.0
const JUMP_CUT_MULT = 0.45
@export var STEP_RATE: float = 0.05

var hp: int = 4
var invincible: bool = false
var inv_timer: float = 0.0
var dead: bool = false
var death_timer: float = 0.0
var facing_right: bool = true
var coyote_timer: float = 0.0
var jump_buf: float = 0.0
var atk_timer: float = 0.0
var atk_active: float = 0.0
var attacking: bool = false
var attack_hits: Dictionary = {}
var sh_active: bool = false
var sh_pos: Vector2 = Vector2.ZERO
var step_phase: float = 0.0
var last_mob_anim: String = ""
var last_step_idx: int = -1
var hurt_anim: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var atk_area: Area2D = $AttackArea
@onready var atk_shape: CollisionShape2D = $AttackArea/AS2
@onready var sh_vis: Sprite2D = $ShadowSprite
@onready var plight: PointLight2D = $PowerLight

signal died

func _ready():
	add_to_group("player")
	_ensure_sprite_frames()
	_configure_attack_hitbox()
	atk_area.monitoring = false
	atk_area.collision_mask = 4
	atk_area.body_entered.connect(_on_hit)
	if sh_vis: sh_vis.visible = false
	if plight: plight.enabled = false
	if anim and not anim.animation_finished.is_connected(_on_anim_finished):
		anim.animation_finished.connect(_on_anim_finished)
	# Ensure an initial animation is playing so frames and fps apply across scenes
	if anim and anim.animation:
		anim.play(anim.animation)
		anim.frame = 0

func _physics_process(dt: float):
	if dead:
		death_timer += dt
		if death_timer > 2.0:
			Global.player_died_stat()
			Global.lives -= 1
			emit_signal("lives_changed", Global.lives)
			if Global.lives <= 0:
				Global.game_over()
			else:
				get_tree().reload_current_scene()
		return

	# Invincibility flash
	if invincible:
		inv_timer -= dt
		anim.modulate.a = 0.35 if fmod(inv_timer, 0.14) > 0.07 else 1.0
		if inv_timer <= 0.0:
			invincible = false
			anim.modulate.a = 1.0

	# Gravity + coyote
	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * dt, MAX_FALL)
		coyote_timer -= dt
	else:
		coyote_timer = COYOTE_T
		if velocity.y > 200.0 and is_on_floor():
			AudioMgr.land()

	# Shadow energy regen when not anchored
	if not sh_active:
		Global.regen_shadow(SHADOW_REGEN, dt)

	# Horizontal movement
	var dir = Input.get_axis("move_left", "move_right")
	var spd = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
	if dir != 0.0:
		var accel = GROUND_ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, dir * spd, accel * dt)
		facing_right = dir > 0.0
		anim.flip_h = not facing_right
		_sync_attack_hitbox()
	else:
		var friction = GROUND_FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0.0, friction * dt)

	# Jump buffering
	jump_buf -= dt
	if Input.is_action_just_pressed("jump"):
		jump_buf = JUMP_BUF_T
	if jump_buf > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VEL
		coyote_timer = 0.0
		jump_buf = 0.0
		AudioMgr.jump()
	elif Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT_MULT

	# Attack
	atk_timer -= dt
	if atk_timer < 0.0:
		atk_timer = 0.0
	if atk_active > 0.0:
		atk_active -= dt
		if atk_active <= 0.0:
			atk_active = 0.0
			# stop hit detection but keep `attacking` true until animation finishes
			atk_area.monitoring = false
	if Input.is_action_just_pressed("attack") and atk_timer <= 0.0 and atk_active <= 0.0:
		_start_attack()

	# Shadow power
	if Input.is_action_just_pressed("shadow_power"):
		if not sh_active and Global.shadow_energy > 20.0:
			sh_active = true
			sh_pos = global_position
			Global.shadow_anchored = true
			Global.shadow_anchor_pos = sh_pos
			if sh_vis:
				sh_vis.global_position = sh_pos
				sh_vis.visible = true
			if plight: plight.enabled = true
			AudioMgr.shadow_on()
		elif sh_active:
			global_position = sh_pos
			sh_active = false
			Global.shadow_anchored = false
			if sh_vis: sh_vis.visible = false
			if plight: plight.enabled = false
			AudioMgr.shadow_off()

	if sh_active:
		Global.drain_shadow(SHADOW_DRAIN * dt)
		if Global.shadow_energy <= 0.0:
			sh_active = false
			Global.shadow_anchored = false
			if sh_vis: sh_vis.visible = false
			if plight: plight.enabled = false

	# update animations based on current velocities and state
	_update_anim(dt)

	move_and_slide()

	# Check physical collisions for contact damage (player moving into enemy)
	var sc = get_slide_collision_count()
	for i in range(sc):
		var col = get_slide_collision(i)
		if not col:
			continue
		var collider = col.get_collider()
		if collider and collider.is_in_group("enemy") and is_instance_valid(collider) and not invincible:
			if collider.has_method("take_damage"):
				# Ask enemy to damage player via contact (enemy position passed for knockback)
				take_damage(false, collider.global_position, "enemy")
			else:
				take_damage(false, collider.global_position, "enemy")

	# Ensure animation frame signal connected (in case anim assigned later)
	if anim and not anim.frame_changed.is_connected(_on_anim_frame_changed):
		anim.frame_changed.connect(_on_anim_frame_changed)
	if atk_active > 0.0:
		_apply_attack_hits()

	# Prevent falling into the void: clamp to camera limits or safe Y
	var cam := get_viewport().get_camera_2d()
	if cam:
		var bottom_limit = cam.limit_bottom
		if bottom_limit != 0 and global_position.y > bottom_limit + 8:
			global_position.y = bottom_limit - 24
			velocity.y = 0
			if anim:
				anim.play("cesar_idle")
	else:
		# fallback: soft clamp to a safe Y instead of dying
		if global_position.y > 1200.0:
			global_position.y = 1200.0
			velocity.y = 0

func _configure_attack_hitbox():
	if atk_shape and atk_shape.shape is RectangleShape2D:
		(atk_shape.shape as RectangleShape2D).size = ATTACK_SIZE
	_sync_attack_hitbox()

func _sync_attack_hitbox():
	if atk_area:
		atk_area.position.x = ATTACK_OFFSET if facing_right else -ATTACK_OFFSET

func _start_attack():
	attacking = true
	atk_timer = ATTACK_COOLDOWN_T
	atk_active = ATTACK_ACTIVE_T
	attack_hits.clear()
	atk_area.monitoring = true
	_apply_attack_hits()
	AudioMgr.attack()

func _apply_attack_hits():
	if not atk_area.monitoring:
		return
	# Primary: use AttackArea overlaps
	for body in atk_area.get_overlapping_bodies():
		_register_attack_hit(body)

	# Fallback: some scenes may have mismatched collision layers/masks.
	# Also check all enemies in the scene and test their global_position against
	# a simple attack rectangle in front of the player.
	var attack_center = global_position + Vector2(ATTACK_OFFSET if facing_right else -ATTACK_OFFSET, 0)
	var attack_rect = Rect2(attack_center - ATTACK_SIZE * 0.5, ATTACK_SIZE)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var id = enemy.get_instance_id()
		if attack_hits.has(id):
			continue
		# Use enemy global_position as a cheap test; this should catch most hits
		if attack_rect.has_point(enemy.global_position):
			_register_attack_hit(enemy)

func _register_attack_hit(body: Node2D):
	if not is_instance_valid(body):
		return
	if not body.is_in_group("enemy"):
		return
	var id = body.get_instance_id()
	if attack_hits.has(id):
		return
	attack_hits[id] = true
	if body.has_method("take_hit"):
		body.take_hit(global_position)

func _update_anim(dt: float):
	if dead:
		_play("cesar_damage", 1.0)
		return
	if hurt_anim:
		_play("cesar_damage", 1.0)
		return
	if attacking:
		_play("cesar_attack", 1.15)
		return
	if not is_on_floor():
		_play("cesar_jump", 1.0)
		return

	var dir = Input.get_axis("move_left", "move_right")
	var speed = abs(velocity.x)
	# Give movement intent priority so idle does not win while the player is still walking.
	if dir != 0.0 and speed > 8.0:
		if speed > RUN_SPEED * 0.7:
			_advance_step_anim("cesar_run", dt)
		else:
			_advance_step_anim("cesar_walk", dt)
	elif speed > RUN_SPEED * 0.7:
		_advance_step_anim("cesar_run", dt)
	elif speed > 8.0:
		_advance_step_anim("cesar_walk", dt)
	else:
		# idle
		last_mob_anim = ""
		_play("cesar_idle", 0.95)

func _advance_step_anim(anim_name: String, _dt: float):
	# Use AnimatedSprite2D playback and adjust speed_scale based on velocity
	var _base_fps = 8.0
	if anim.sprite_frames and anim.sprite_frames.has_animation(anim_name):
		# ensure animation playing
		if anim.animation != anim_name:
			anim.play(anim_name)
			anim.frame = 0
		# scale speed: mapping velocity to speed multiplier
		var speed_ratio = clamp(abs(velocity.x) / RUN_SPEED, 0.1, 1.6)
		anim.speed_scale = 0.8 + speed_ratio * 1.2
	else:
		anim.play(anim_name)
		anim.frame = 0
	last_mob_anim = anim_name

func _on_anim_frame_changed():
	var a = anim.animation
	if a == "cesar_walk":
		if anim.frame % 2 == 0:
			AudioMgr.footstep_walk()
	elif a == "cesar_run":
		if anim.frame % 2 == 0:
			AudioMgr.footstep_run()

func _on_anim_finished(anim_name = ""):
	var current_name = anim_name
	if current_name == "":
		current_name = anim.animation
	if current_name == "cesar_attack":
		attacking = false
		atk_active = 0.0
		atk_area.monitoring = false
	elif current_name == "cesar_damage":
		hurt_anim = false

func _play(a: String, speed: float = 1.0):
	anim.speed_scale = speed
	if anim.animation != a:
		anim.play(a)
		anim.frame = 0

func take_damage(instant: bool = false, from = null, source: String = "enemy"):
	if invincible or dead:
		return
	if source != "enemy" and source != "spikes":
		return
	Global.hit_player()
	if source == "spikes":
		hp -= 1
		invincible = true
		inv_timer = 0.9
		AudioMgr.hurt()
		velocity.y = min(velocity.y, -620.0)
		if from != null:
			var dir = sign(global_position.x - from.x)
			velocity.x = 300.0 * dir
	else:
		if instant:
			hp = 0
		else:
			hp -= 1
			invincible = true
			inv_timer = 1.3
			AudioMgr.hurt()
			if from != null:
				var dir = sign(global_position.x - from.x)
				velocity.x = 260.0 * dir
				velocity.y = -180.0
	if hp <= 0:
		_die()

func _die():
	dead = true
	velocity = Vector2.ZERO
	atk_active = 0.0
	attacking = false
	atk_area.monitoring = false
	collision_layer = 0
	collision_mask = 0
	anim.speed_scale = 1.0
	anim.play("cesar_damage")
	AudioMgr.die()
	emit_signal("died")

func pick_crystal():
	Global.pick_crystal()
	AudioMgr.crystal_sfx()

func _on_hit(body: Node2D):
	_register_attack_hit(body)

func _ensure_sprite_frames():
	if not anim:
		return
	var sf = anim.sprite_frames
	if sf and sf.get_animation_names().size() > 0:
		return
	var frames = SpriteFrames.new()
	var dir = DirAccess.open("res://assets/sprites/cesar")
	if not dir:
		return
	dir.list_dir_begin()
	var f = dir.get_next()
	var files = []
	while f != "":
		if not dir.current_is_dir() and (f.ends_with(".png") or f.ends_with(".webp")):
			files.append(f)
		f = dir.get_next()
	dir.list_dir_end()
	files.sort()
	for file in files:
		var fname = file.get_basename()
		var parts = fname.split("_")
		if parts.size() >= 2:
			var anim_name = parts[0] + "_" + parts[1]
			if not frames.has_animation(anim_name):
				frames.add_animation(anim_name)
			var tex = load("res://assets/sprites/cesar/" + file)
			frames.add_frame(anim_name, tex)

	# Configure loops and FPS for common animations so frames fully play
	var loop_map = {
		"cesar_idle": true,
		"cesar_walk": true,
		"cesar_run": true,
		"cesar_attack": false,
		"cesar_damage": false,
		"cesar_jump": false
	}
	var fps_map = {
		"cesar_idle": 6,
		"cesar_walk": 8,
		"cesar_run": 12,
		"cesar_attack": 12,
		"cesar_damage": 10,
		"cesar_jump": 8
	}
	for anim_name in frames.get_animation_names():
		var loop = true
		if loop_map.has(anim_name):
			loop = loop_map[anim_name]
		frames.set_animation_loop(anim_name, loop)
		var fps = 8
		if fps_map.has(anim_name):
			fps = fps_map[anim_name]
		frames.set_animation_speed(anim_name, fps)
	if frames.get_animation_names().size() > 0:
		anim.sprite_frames = frames
		anim.animation = frames.get_animation_names()[0]
		anim.frame = 0

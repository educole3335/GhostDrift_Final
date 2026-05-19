extends Node2D

@export var level_num: int = 1
@export var music: String = "lvl1"

var door_unlocked: bool = false
var enemy_count: int = 0
var level_done: bool = false
@export var min_kills: int = 4
const OBJECTS_SPAWNER = preload("res://scripts/ObjectsSpawner.gd")

@onready var exit_door: Area2D = $ExitDoor
@onready var pause_ui: CanvasLayer = $PauseUI
@onready var results_ui: CanvasLayer = $ResultsUI
@onready var hud: CanvasLayer = $HUD

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.reset_level()
	# Ensure global current level matches this level scene so HUD and requirements sync
	Global.current_level = level_num
	AudioMgr.play_music(music)
	enemy_count = get_tree().get_nodes_in_group("enemy").size()
	# instantiate objects spawner (non-destructive)
	if OBJECTS_SPAWNER:
		var sp = OBJECTS_SPAWNER.new()
		add_child(sp)
	if exit_door:
		exit_door.monitoring = false
		exit_door.body_entered.connect(_on_exit)
	if pause_ui: pause_ui.visible = false
	if results_ui: results_ui.visible = false
	# Keep HUD visible during gameplay
	if hud:
		hud.visible = true

	# Ensure camera limits fit the level so camera doesn't show outside the scene
	_adjust_camera_limits()

func _compute_level_bounds() -> Rect2:
	var min_v = Vector2(1e9, 1e9)
	var max_v = Vector2(-1e9, -1e9)
	var stack = [ self ]
	while stack.size() > 0:
		var n = stack.pop_back()
		if n is Node2D:
			var p = n.global_position
			min_v.x = min(min_v.x, p.x)
			min_v.y = min(min_v.y, p.y)
			max_v.x = max(max_v.x, p.x)
			max_v.y = max(max_v.y, p.y)
		for c in n.get_children():
			if c is Node:
				stack.append(c)
	if min_v.x > max_v.x:
		# fallback small rect
		return Rect2(Vector2.ZERO, Vector2(1280, 720))
	return Rect2(min_v, max_v - min_v)

func _adjust_camera_limits():
	# Find Camera2D under Player or anywhere in scene
	var cam: Camera2D = null
	cam = get_viewport().get_camera_2d()
	if not cam:
		return
	var bounds = _compute_level_bounds()
	# apply padding
	var pad = 24
	cam.limit_left = int(bounds.position.x) - pad
	cam.limit_top = int(bounds.position.y) - pad
	cam.limit_right = int(bounds.position.x + bounds.size.x) + pad
	cam.limit_bottom = int(bounds.position.y + bounds.size.y) + pad

func _process(_dt: float):
	# Only advance game logic when not paused
	if not get_tree().paused:
		Global.tick()
	if level_done:
		return
	if not door_unlocked:
		# Require collecting all crystals (if any) AND killing minimum enemies to unlock
		var total_c = Global.CRYSTALS_PER.get(Global.current_level, 0)
		var kills = Global.enemies_killed
		var required_kills = _required_kills()
		if total_c > 0:
			if Global.crystals_collected >= total_c and kills >= required_kills:
				_unlock_door()
			else:
				# Show short hint about missing requirements
				var hud_node = get_tree().get_first_node_in_group("hud")
				if hud_node and hud_node.has_method("hint"):
					var need_c = max(0, total_c - Global.crystals_collected)
					var need_k = max(0, required_kills - kills)
					var msg = ""
					if need_c > 0:
						msg += "Recoge %d gemas más. " % need_c
					if need_k > 0:
						msg += "Elimina %d enemigos más." % need_k
					if msg != "":
						hud_node.hint(msg, 2.0)
		else:
			# No crystals defined: fallback to clearing enemies and minimum kills
			var alive = get_tree().get_nodes_in_group("enemy").size()
			if alive == 0 and enemy_count > 0 and kills >= required_kills:
				_unlock_door()

func _input(_ev: InputEvent):
	if Input.is_action_just_pressed("ui_pause") and not level_done:
		if get_tree().paused:
			if pause_ui:
				pause_ui.visible = false
			get_tree().paused = false
			AudioMgr.pause_sfx()
		else:
			if pause_ui:
				pause_ui.visible = true
			get_tree().paused = true
			AudioMgr.pause_sfx()

func _unlock_door():
	door_unlocked = true
	AudioMgr.door_open()
	if exit_door:
		exit_door.monitoring = true
		# Pulsing glow on exit
		var ev = exit_door.get_node_or_null("ExitVis")
		if ev:
			var tw = create_tween().set_loops()
			tw.tween_property(ev, "modulate", Color(1, 1, 0.2, 1), 0.5)
			tw.tween_property(ev, "modulate", Color(0.2, 1, 0.2, 1), 0.5)
	# HUD hint
	var hud_node = get_tree().get_first_node_in_group("hud")
	if hud_node and hud_node.has_method("hint"):
		hud_node.hint("Objetivo completado.  Cruza la puerta EXIT  ➜", 4.0)

func _required_kills() -> int:
	var progressive = min_kills + max(0, level_num - 1)
	if enemy_count > 0:
		return min(progressive, enemy_count)
	return progressive

func _on_exit(body: Node2D):
	if not body.is_in_group("player") or level_done:
		return
	level_done = true
	Global.add_score(1000 * level_num)
	# Recover 1 life when the player completes the level
	Global.add_life(1)
	await get_tree().create_timer(0.6).timeout
	if results_ui and results_ui.has_method("show_results"):
		results_ui.show_results()

extends Node2D

@export var level_num: int = 1
@export var music: String = "lvl1"

var door_unlocked: bool = false
var enemy_count: int = 0
var level_done: bool = false
const OBJECTS_SPAWNER = preload("res://scripts/ObjectsSpawner.gd")

@onready var exit_door: Area2D = $ExitDoor
@onready var pause_ui: CanvasLayer = $PauseUI
@onready var results_ui: CanvasLayer = $ResultsUI

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.reset_level()
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

func _process(_dt: float):
	# Only advance game logic when not paused
	if not get_tree().paused:
		Global.tick()
	if level_done:
		return
	if not door_unlocked:
		var alive = get_tree().get_nodes_in_group("enemy").size()
		if alive == 0 and enemy_count > 0:
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
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("hint"):
		hud.hint("¡Todos eliminados!  Cruza la puerta EXIT  ➜", 4.0)

func _on_exit(body: Node2D):
	if not body.is_in_group("player") or level_done:
		return
	level_done = true
	Global.add_score(1000 * level_num)
	await get_tree().create_timer(0.6).timeout
	if results_ui and results_ui.has_method("show_results"):
		results_ui.show_results()

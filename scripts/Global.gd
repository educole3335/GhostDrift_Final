extends Node

var score: int = 0
var lives: int = 4
var max_lives: int = 4
var current_level: int = 1
var total_levels: int = 5

var shadow_energy: float = 100.0
var max_shadow_energy: float = 100.0
var shadow_anchored: bool = false
var shadow_anchor_pos: Vector2 = Vector2.ZERO

var has_dash: bool = false
var held_keys: Array = []
var combo_level: int = 0

# Level stats
var level_start_time: float = 0.0
var level_elapsed: float = 0.0
var crystals_collected: int = 0
var enemies_killed: int = 0
var deaths_this_level: int = 0
var damage_taken: int = 0
var level_stars: Dictionary = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}

const LEVEL_NAMES = {
	1: "Ruinas Sombrías",
	2: "Bosque Tenebroso",
	3: "Minas Profundas",
	4: "Torre del Olvido",
	5: "Santuario Final"
}
const LEVEL_SCENES = {
	1: "res://scenes/Level1.tscn",
	2: "res://scenes/Level2.tscn",
	3: "res://scenes/Level3.tscn",
	4: "res://scenes/Level4.tscn",
	5: "res://scenes/Level5.tscn"
}
const LEVEL_PAR = {1: 90, 2: 120, 3: 150, 4: 180, 5: 240}
const CRYSTALS_PER = {1: 5, 2: 5, 3: 5, 4: 5, 5: 5}

signal score_changed(v)
signal shadow_changed(v)
signal crystal_picked(v)
signal lives_changed(v)
signal enemy_killed(v)

func reset():
	score = 0; lives = max_lives; current_level = 1
	shadow_energy = max_shadow_energy; shadow_anchored = false
	crystals_collected = 0; enemies_killed = 0
	deaths_this_level = 0; damage_taken = 0
	has_dash = false; held_keys = []; combo_level = 0

func reset_level():
	level_start_time = Time.get_ticks_msec() / 1000.0
	level_elapsed = 0.0; crystals_collected = 0; enemies_killed = 0
	deaths_this_level = 0; damage_taken = 0
	shadow_energy = max_shadow_energy; shadow_anchored = false

func tick():
	level_elapsed = (Time.get_ticks_msec() / 1000.0) - level_start_time

func add_score(pts: int):
	score += pts
	emit_signal("score_changed", score)

func kill_enemy():
	enemies_killed += 1
	add_score(250)
	emit_signal("enemy_killed", enemies_killed)

func hit_player():
	damage_taken += 1

func player_died_stat():
	deaths_this_level += 1

func pick_crystal():
	crystals_collected += 1
	add_score(200)
	emit_signal("crystal_picked", crystals_collected)

func add_life(amount: int = 1):
	if amount <= 0:
		return
	lives = min(max_lives, lives + amount)
	emit_signal("lives_changed", lives)

func drain_shadow(amount: float):
	shadow_energy = max(0.0, shadow_energy - amount)
	emit_signal("shadow_changed", shadow_energy)

func regen_shadow(amount: float, dt: float):
	shadow_energy = min(max_shadow_energy, shadow_energy + amount * dt)
	emit_signal("shadow_changed", shadow_energy)

func calc_stars() -> int:
	var stars = 3
	var par = LEVEL_PAR.get(current_level, 120)
	var total_c = CRYSTALS_PER.get(current_level, 5)
	if level_elapsed > par * 2.0:
		stars -= 1
	if damage_taken > 3 or deaths_this_level > 0:
		stars -= 1
	if crystals_collected < int(total_c / 2):
		stars -= 1
	stars = max(0, stars)
	if stars > level_stars.get(current_level, 0):
		level_stars[current_level] = stars
	return stars

func get_result() -> Dictionary:
	return {
		"level": current_level,
		"name": LEVEL_NAMES.get(current_level, "?"),
		"time": level_elapsed,
		"par": LEVEL_PAR.get(current_level, 120),
		"crystals": crystals_collected,
		"total_c": CRYSTALS_PER.get(current_level, 5),
		"enemies": enemies_killed,
		"deaths": deaths_this_level,
		"damage": damage_taken,
		"score": score,
		"stars": calc_stars()
	}

func next_level():
	current_level += 1
	if current_level > total_levels:
		get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
	else:
		get_tree().change_scene_to_file(LEVEL_SCENES[current_level])

func game_over():
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func lvl_name() -> String:
	return LEVEL_NAMES.get(current_level, "?")

func total_stars() -> int:
	var s = 0
	for n in level_stars:
		s += level_stars[n]
	return s

func give_dash(value: bool):
	has_dash = value

func give_key(key_id: String):
	if not held_keys.has(key_id):
		held_keys.append(key_id)

func upgrade_combo(level: int):
	if level > combo_level:
		combo_level = level

func toggle_fs():
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func reset_score():
	score = 0
	emit_signal("score_changed", score)

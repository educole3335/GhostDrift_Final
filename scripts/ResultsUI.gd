extends CanvasLayer

@onready var title_lbl: Label = $Panel/VBox/Title
@onready var stars_lbl: Label = $Panel/VBox/Stars
@onready var time_lbl: Label = $Panel/VBox/Stats/Time
@onready var crystal_lbl: Label = $Panel/VBox/Stats/Crystals
@onready var enemy_lbl: Label = $Panel/VBox/Stats/Enemies
@onready var death_lbl: Label = $Panel/VBox/Stats/Deaths
@onready var score_lbl: Label = $Panel/VBox/Stats/Score
@onready var btn_next: Button = $Panel/VBox/Btns/Next
@onready var btn_retry: Button = $Panel/VBox/Btns/Retry
@onready var btn_menu: Button = $Panel/VBox/Btns/Menu

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	btn_next.pressed.connect(func():
		get_tree().paused = false
		AudioMgr.ui_click()
		Global.next_level()
	)
	btn_retry.pressed.connect(func():
		get_tree().paused = false
		AudioMgr.ui_click()
		get_tree().change_scene_to_file(Global.LEVEL_SCENES[Global.current_level])
	)
	btn_menu.pressed.connect(func():
		get_tree().paused = false
		AudioMgr.ui_click()
		Global.reset()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)

func show_results():
	visible = true
	get_tree().paused = true

	await get_tree().create_timer(0.3, true).timeout
	AudioMgr.lvl_done()
	await get_tree().create_timer(0.5, true).timeout
	AudioMgr.stars_sfx()

	var r = Global.get_result()

	if title_lbl:
		title_lbl.text = "Nivel %d completado!
%s" % [r.level, r.name]

	var t = int(r.time)
	var par = int(r.par)
	var tms = _min_sec(t)
	var pms = _min_sec(par)
	if time_lbl:
		time_lbl.text = "⏱  %d:%02d   (par: %d:%02d)" % [tms[0], tms[1], pms[0], pms[1]]
	if crystal_lbl:
		crystal_lbl.text = "💎  Cristales: %d / %d" % [r.crystals, r.total_c]
	if enemy_lbl:
		enemy_lbl.text = "💀  Enemigos eliminados: %d" % r.enemies
	if death_lbl:
		death_lbl.text = "☠  Muertes: %d   |   Golpes recibidos: %d" % [r.deaths, r.damage]
	if score_lbl:
		score_lbl.text = "★  Puntuación: %06d" % r.score

	var s = r.stars
	if stars_lbl:
		match s:
			3: stars_lbl.text = "⭐  ⭐  ⭐"; stars_lbl.modulate = Color(1.0, 0.90, 0.1)
			2: stars_lbl.text = "⭐  ⭐  ☆"; stars_lbl.modulate = Color(0.9, 0.80, 0.2)
			1: stars_lbl.text = "⭐  ☆  ☆"; stars_lbl.modulate = Color(0.7, 0.70, 0.7)
			_: stars_lbl.text = "☆  ☆  ☆"; stars_lbl.modulate = Color(0.45, 0.45, 0.45)

	if btn_next and r.level >= Global.total_levels:
		btn_next.text = "🏆  Ver victoria"

func _min_sec(seconds: int) -> Array:
	var s = int(seconds)
	var mins = 0
	while s >= 60:
		s -= 60
		mins += 1
	return [mins, s]

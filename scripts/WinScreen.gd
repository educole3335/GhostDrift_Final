extends Node2D

@onready var score_lbl: Label  = $UI/Panel/VBox/Score
@onready var stars_row: Label  = $UI/Panel/VBox/StarsRow
@onready var best_msg:  Label  = $UI/Panel/VBox/BestMsg
@onready var btn_menu:  Button = $UI/Panel/VBox/Menu

func _ready():
	AudioMgr.play_music("win")
	await get_tree().create_timer(0.5).timeout
	AudioMgr.stars_sfx()

	if score_lbl:
		score_lbl.text = "Puntuación final: %06d" % Global.score

	var total = Global.total_stars()
	var max_s = Global.total_levels * 3
	if stars_row:
		stars_row.text = "Estrellas totales: %d / %d" % [total, max_s]

	if best_msg:
		if total == max_s:
			best_msg.text    = "🏆 ¡Perfecto! ¡Todas las estrellas!"
			best_msg.modulate = Color(1, 0.9, 0.1)
		elif total >= max_s * 2 / 3:
			best_msg.text    = "⭐ ¡Excelente trabajo, gran explorador!"
		else:
			best_msg.text    = "Sigue entrenando para conseguir todas las estrellas"
			best_msg.modulate = Color(0.7, 0.9, 0.7)

	btn_menu.pressed.connect(func():
		AudioMgr.ui_click()
		Global.reset()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)

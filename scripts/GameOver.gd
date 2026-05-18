extends Node2D

@onready var score_lbl: Label  = $UI/Panel/VBox/Score
@onready var btn_retry: Button = $UI/Panel/VBox/Retry
@onready var btn_menu:  Button = $UI/Panel/VBox/Menu

func _ready():
	AudioMgr.play_music("over")
	if score_lbl:
		score_lbl.text = "Puntuación: %06d" % Global.score
	btn_retry.pressed.connect(func():
		AudioMgr.ui_click()
		Global.lives = Global.max_lives
		get_tree().change_scene_to_file(Global.LEVEL_SCENES[Global.current_level])
	)
	btn_menu.pressed.connect(func():
		AudioMgr.ui_click()
		Global.reset()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)

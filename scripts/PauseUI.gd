extends CanvasLayer

@onready var btn_resume:  Button  = $Panel/VBox/BtnResume
@onready var btn_restart: Button  = $Panel/VBox/BtnRestart
@onready var btn_fs:      Button  = $Panel/VBox/BtnFS
@onready var btn_menu:    Button  = $Panel/VBox/BtnMenu
@onready var music_sl:    HSlider = $Panel/VBox/MusicSlider
@onready var sfx_sl:      HSlider = $Panel/VBox/SFXSlider

func _ready():
	visible = false
	btn_resume.pressed.connect(_resume)
	btn_restart.pressed.connect(_restart)
	btn_fs.pressed.connect(_fullscreen)
	btn_menu.pressed.connect(_menu)
	if music_sl:
		music_sl.value = 60.0
		music_sl.value_changed.connect(func(v):
			AudioMgr.music_player.volume_db = linear_to_db(v / 100.0)
		)
	if sfx_sl:
		sfx_sl.value = 80.0

func _resume():
	visible = false
	get_tree().paused = false
	AudioMgr.ui_click()

func _restart():
	get_tree().paused = false
	AudioMgr.ui_click()
	get_tree().change_scene_to_file(Global.LEVEL_SCENES[Global.current_level])

func _fullscreen():
	Global.toggle_fs()
	AudioMgr.ui_click()

func _menu():
	get_tree().paused = false
	AudioMgr.ui_click()
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

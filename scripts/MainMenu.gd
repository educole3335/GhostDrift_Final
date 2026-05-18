extends Node2D

@onready var btn_play:  Button         = $UI/VBox/BtnPlay
@onready var btn_ctrl:  Button         = $UI/VBox/BtnCtrl
@onready var btn_fs:    Button         = $UI/VBox/BtnFS
@onready var btn_quit:  Button         = $UI/VBox/BtnQuit
@onready var ctrl_panel: PanelContainer = $UI/CtrlPanel

func _ready():
	Global.reset()
	AudioMgr.play_music("menu")
	btn_play.pressed.connect(func():
		AudioMgr.ui_click()
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")
	)
	btn_ctrl.pressed.connect(func():
		AudioMgr.ui_click()
		ctrl_panel.visible = not ctrl_panel.visible
	)
	btn_fs.pressed.connect(func():
		AudioMgr.ui_click()
		Global.toggle_fs()
	)
	btn_quit.pressed.connect(func():
		AudioMgr.ui_click()
		get_tree().quit()
	)
	if ctrl_panel:
		ctrl_panel.visible = false

func _input(ev: InputEvent):
	if ev.is_action_pressed("ui_pause") and ctrl_panel and ctrl_panel.visible:
		ctrl_panel.visible = false

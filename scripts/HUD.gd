extends CanvasLayer

@onready var score_lbl: Label = $Top/HBox/Score
@onready var lives_lbl: Label = $Top/HBox/Lives
@onready var level_lbl: Label = $Top/HBox/LvlName
@onready var time_lbl: Label = $Top/HBox/Time
@onready var crystal_lbl: Label = $Top/HBox/Crystals
@onready var kills_lbl: Label = $Top/HBox/Kills
@onready var sh_bar: ProgressBar = $Bot/ShadowBar
@onready var sh_lbl: Label = $Bot/ShadowLbl
@onready var hint_lbl: Label = $HintLbl

var hint_t: float = 0.0

func _ready():
	add_to_group("hud")
	Global.score_changed.connect(_on_score)
	Global.shadow_changed.connect(_on_shadow)
	Global.crystal_picked.connect(_on_crystal)
	Global.enemy_killed.connect(_on_enemy_killed)
	# connect lives change to refresh HUD lives display
	if Global.has_signal("lives_changed"):
		Global.lives_changed.connect(_on_lives_changed)
	_refresh()

func _process(dt: float):
	Global.tick()
	if time_lbl:
		var s = int(Global.level_elapsed)
		var mins = int(s / 60.0)
		time_lbl.text = "%d:%02d" % [mins, s % 60]
	if sh_bar:
		sh_bar.value = (Global.shadow_energy / Global.max_shadow_energy) * 100.0
	if hint_lbl and hint_lbl.visible:
		hint_t -= dt
		if hint_t <= 0.0:
			hint_lbl.visible = false

func _refresh():
	if score_lbl: score_lbl.text = "%06d" % Global.score
	if lives_lbl: _update_lives()
	if level_lbl: level_lbl.text = "Nv.%d — %s" % [Global.current_level, Global.lvl_name()]
	var tot = Global.CRYSTALS_PER.get(Global.current_level, 5)
	if crystal_lbl: crystal_lbl.text = "💎 0/%d" % tot
	_update_kills()

func _update_lives():
	if not lives_lbl: return
	var h = "❤ ".repeat(max(0, Global.lives))
	h += "🖤 ".repeat(max(0, Global.max_lives - Global.lives))
	lives_lbl.text = h.strip_edges()

func _on_score(v: int):
	if score_lbl: score_lbl.text = "%06d" % v

func _on_shadow(v: float):
	if sh_bar: sh_bar.value = (v / Global.max_shadow_energy) * 100.0
	if sh_lbl:
		if Global.shadow_anchored:
			sh_lbl.text = "⬡ SOMBRA ANCLADA — X para intercambiar"
			sh_lbl.modulate = Color(0.9, 0.5, 1.0)
		else:
			sh_lbl.text = "◈ Sombra %.0f%%   [X = anclar]" % ((v / Global.max_shadow_energy) * 100.0)
			sh_lbl.modulate = Color(0.7, 0.6, 1.0)

func _on_crystal(v: int):
	var tot = Global.CRYSTALS_PER.get(Global.current_level, 5)
	if crystal_lbl: crystal_lbl.text = "💎 %d/%d" % [v, tot]

func _on_enemy_killed(v: int):
	if kills_lbl:
		kills_lbl.text = "💀 %d/%d" % [v, _required_kills()]

func _update_kills():
	if kills_lbl:
		kills_lbl.text = "💀 %d/%d" % [Global.enemies_killed, _required_kills()]

func _required_kills() -> int:
	var min_kills = 4
	var progressive = min_kills + max(0, Global.current_level - 1)
	var enemy_count = get_tree().get_nodes_in_group("enemy").size()
	if enemy_count > 0:
		return min(progressive, enemy_count)
	return progressive

func hint(text: String, duration: float = 3.5):
	if hint_lbl:
		hint_lbl.text = text
		hint_lbl.visible = true
		hint_t = duration

func update_lives():
	_update_lives()

func _on_lives_changed(_v: int):
	_update_lives()

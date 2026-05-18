extends Node

var music_player: AudioStreamPlayer
var sfx_pool: Array = []
var cur_music: String = ""

func _ready():
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_pool.append(p)
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -8.0
	add_child(music_player)

func play_music(track: String):
	if cur_music == track:
		return
	cur_music = track
	var params = {
		"menu": [220.0, false, 80],
		"lvl1": [196.0, false, 95],
		"lvl2": [174.6, false, 90],
		"lvl3": [164.8, false, 105],
		"lvl4": [185.0, false, 110],
		"lvl5": [146.8, false, 130],
		"over": [130.8, false, 60],
		"win": [261.6, true, 120]
	}
	var p = params.get(track, params["menu"])
	var wav = _gen(p[0], p[1], p[2])
	music_player.stream = wav
	music_player.volume_db = linear_to_db(0.6)
	music_player.play()

func _gen(base: float, major: bool, tempo: int) -> AudioStreamWAV:
	var sr = 22050
	var beats = 16
	var bd = 60.0 / tempo
	var total = int(sr * bd * beats)
	var data = PackedByteArray()
	data.resize(total * 2)
	var minor = [0, 2, 3, 5, 7, 8, 10, 12]
	var maj = [0, 2, 4, 5, 7, 9, 11, 12]
	var scale = maj if major else minor
	var mel = [0, 2, 4, 2, 5, 3, 1, 0, 4, 5, 3, 2, 0, 2, 4, 3]
	for beat in range(beats):
		var semi = scale[mel[beat % mel.size()] % scale.size()]
		var freq = base * pow(2.0, semi / 12.0)
		var s = int(beat * bd * sr)
		var e = int((beat + 0.82) * bd * sr)
		for i in range(s, min(e, total)):
			var t = float(i - s) / sr
			var env = min(1.0, t * 8.0) * max(0.0, 1.0 - (t / (bd * 0.82)) * 1.2)
			var w = (sin(2.0 * PI * freq * t) * 0.5 + sin(2.0 * PI * freq * 2.0 * t) * 0.18) * env * 0.18
			var sam = int(clamp(w, -1.0, 1.0) * 32767)
			data[i * 2] = sam & 0xFF
			data[i * 2 + 1] = (sam >> 8) & 0xFF
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sr
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total
	return wav

func _tone(freqs: Array, durs: Array, amp: float = 0.38):
	var sr = 22050
	var total = 0
	for d in durs:
		total += int(d * sr)
	var data = PackedByteArray()
	data.resize(total * 2)
	var idx = 0
	for n in range(freqs.size()):
		var len_s = int(durs[n] * sr)
		for i in range(len_s):
			var t = float(i) / sr
			var env = 1.0 - float(i) / len_s
			var w = sin(2.0 * PI * freqs[n] * t) * amp * env
			var sam = int(clamp(w, -1.0, 1.0) * 32767)
			data[idx] = sam & 0xFF
			data[idx + 1] = (sam >> 8) & 0xFF
			idx += 2
	var wav = AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sr
	wav.stereo = false
	for p in sfx_pool:
		if not p.playing:
			p.stream = wav
			p.volume_db = linear_to_db(0.8)
			p.play()
			return
	sfx_pool[0].stream = wav
	sfx_pool[0].play()

func jump(): _tone([300.0, 480.0, 660.0], [0.04, 0.04, 0.07], 0.35)
func attack(): _tone([200.0, 280.0, 180.0], [0.05, 0.05, 0.08], 0.40)
func land(): _tone([120.0, 90.0], [0.04, 0.06], 0.30)
func hurt(): _tone([220.0, 180.0, 140.0], [0.06, 0.06, 0.10], 0.45)
func die(): _tone([440.0, 370.0, 294.0, 220.0, 147.0], [0.1, 0.1, 0.12, 0.15, 0.4], 0.40)
func crystal_sfx(): _tone([660.0, 880.0, 1100.0, 1320.0], [0.05, 0.05, 0.05, 0.10], 0.30)
func shadow_on(): _tone([180.0, 220.0, 160.0], [0.06, 0.06, 0.10], 0.35)
func shadow_off(): _tone([440.0, 550.0, 440.0, 330.0], [0.05, 0.05, 0.05, 0.10], 0.40)
func enemy_hit(): _tone([280.0, 220.0], [0.05, 0.08], 0.38)
func enemy_die(): _tone([300.0, 240.0, 180.0, 120.0], [0.06, 0.07, 0.09, 0.18], 0.42)
func door_open(): _tone([523.0, 659.0, 784.0, 1047.0], [0.1, 0.1, 0.1, 0.25], 0.35)
func lvl_done(): _tone([523.0, 659.0, 784.0, 1047.0, 1319.0], [0.08, 0.08, 0.08, 0.08, 0.4], 0.40)
func stars_sfx(): _tone([523.0, 659.0, 784.0], [0.12, 0.12, 0.30], 0.35)
func ui_click(): _tone([660.0, 880.0], [0.03, 0.05], 0.25)
func pause_sfx(): _tone([440.0, 330.0], [0.05, 0.08], 0.28)
func lever_sfx(): _tone([300.0, 450.0], [0.06, 0.10], 0.32)
func checkpoint(): _tone([660.0, 780.0, 880.0], [0.08, 0.08, 0.16], 0.30)

func footstep():
	# Short percussive footstep-like sound
	_tone([420.0, 600.0], [0.03, 0.02], 0.28)

func footstep_walk():
	# Softer footstep for walking
	_tone([420.0], [0.03], 0.20)

func footstep_run():
	# Stronger footstep for running
	_tone([360.0, 540.0], [0.02, 0.02], 0.34)

func explosion(): _tone([160.0, 120.0, 90.0, 60.0], [0.06, 0.10, 0.15, 0.30], 0.55)
func pickup(): _tone([880.0, 1100.0, 1320.0], [0.04, 0.04, 0.08], 0.28)

func stop():
	music_player.stop()
	cur_music = ""

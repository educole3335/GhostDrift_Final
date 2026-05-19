extends Node

func _ready():
	# Small delay so editor/runtime has time to settle
	await get_tree().create_timer(0.4).timeout
	if not Engine.is_editor_hint():
		print("AutoFlow: starting automated level flow")
		Global.reset()
		# iterate through levels and advance using Global.next_level()
		for i in range(1, Global.total_levels + 1):
			Global.current_level = i
			var scene_path = Global.LEVEL_SCENES.get(i, null)
			if scene_path == null:
				push_error("AutoFlow: no scene for level %d" % i)
				continue
			print("AutoFlow: loading %s" % scene_path)
			get_tree().change_scene_to_file(scene_path)
			# wait a bit for the scene to initialize
			await get_tree().create_timer(0.8).timeout
			# simulate end-of-level by advancing to next scene
			Global.next_level()
			# wait for the transition
			await get_tree().create_timer(0.6).timeout
		print("AutoFlow: finished — WinScreen should be loaded")

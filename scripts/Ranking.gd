class_name Ranking
extends Node

const SAVE_PATH := "user://scores.save"
const MAX_ENTRIES := 10

func _read_scores() -> Array:
	var scores: Array = []
	var f = FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.READ)
	if f:
		var txt = f.get_as_text()
		f.close()
		if txt != "":
			for line in txt.split("\n"):
				if line.strip_edges() == "":
					continue
				var parts = line.split("|")
				if parts.size() >= 2:
					var nm = parts[0]
					var sc = int(parts[1])
					scores.append({"name": nm, "score": sc})
	return scores

func _write_scores(scores: Array) -> void:
	var f = FileAccess.open(SAVE_PATH, FileAccess.ModeFlags.WRITE)
	if f:
		var lines: Array = []
		for e in scores:
			lines.append("%s|%d" % [str(e.get("name", "Anon")), int(e.get("score", 0))])
		var txt = ""
		for i in range(lines.size()):
			txt += lines[i]
			if i < lines.size() - 1:
				txt += "\n"
		f.store_string(txt)
		f.close()

func save_score(score: int, p_name: String = "Anon") -> void:
	var scores = _read_scores()
	scores.append({"name": p_name, "score": score})
	# sort descending using this instance as comparator
	scores.sort_custom(Callable(self , "_cmp_scores"))
	# keep top N
	if scores.size() > MAX_ENTRIES:
		scores = scores.slice(0, MAX_ENTRIES)
	_write_scores(scores)


func _cmp_scores(a, b):
	var sa = int(a.get("score", 0))
	var sb = int(b.get("score", 0))
	return sb - sa

func get_top(n: int = 10) -> Array:
	var s = _read_scores()
	if n < s.size():
		return s.slice(0, n)
	return s

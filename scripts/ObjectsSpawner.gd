extends Node

const OBJ_PATH = "res://scripts/objects/"

# Area2D-based scripts (need Area2D node, not Node2D)
const AREA2D_TYPES = ["ShadowCoin", "Trampoline", "LavaZone", "WindZone",
		"Key", "DashPickup", "ComboPickup", "PressureButton",
		"ExplosiveBarrel", "ProyectilShadow"]

var level_configs = {
	1: [
		{"type": "ShadowCoin", "pos": Vector2(300, -50)},
		{"type": "ShadowCoin", "pos": Vector2(600, -80)},
		{"type": "ShadowCoin", "pos": Vector2(900, -50)},
		{"type": "Trampoline", "pos": Vector2(800, -30)},
		{"type": "ShadowArcher", "pos": Vector2(1200, -40)}
	],
	2: [
		{"type": "ShadowCoin", "count": 4},
		{"type": "ExplosiveBarrel", "pos": Vector2(1400, -30)},
		{"type": "ShadowArcher", "count": 2},
		{"type": "Trampoline", "pos": Vector2(650, -30)}
	],
	3: [
		{"type": "LavaZone", "pos": Vector2(1100, 0), "size": Vector2(600, 80)},
		{"type": "WindZone", "pos": Vector2(600, -20)},
		{"type": "Specter", "count": 2},
		{"type": "ShadowCoin", "count": 3}
	],
	4: [
		{"type": "PlatformShadow", "count": 3},
		{"type": "PressureButton", "pos": Vector2(900, -20)},
		{"type": "Key", "pos": Vector2(1600, -60)},
		{"type": "ShadowArcher", "count": 2},
		{"type": "ShadowCoin", "count": 2}
	],
	5: [
		{"type": "ShadowArcher", "count": 3},
		{"type": "ExplosiveBarrel", "count": 3},
		{"type": "LavaZone", "pos": Vector2(1000, 0), "size": Vector2(1000, 80)},
		{"type": "Specter", "count": 2},
		{"type": "ShadowCoin", "count": 5}
	]
}

func _ready():
	var lvl = 1
	if get_parent().has_method("get") and get_parent().get("level_num") != null:
		lvl = int(get_parent().get("level_num"))

	var placed_types = []
	var cfg = level_configs.get(lvl, [])
	for item in cfg:
		var t = item.get("type")
		var count = item.get("count", 1)
		for i in range(count):
			_spawn_type(t, item, i)
		if t not in placed_types:
			placed_types.append(t)

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and placed_types.size() > 0:
		var desc = []
		for t in placed_types:
			desc.append(_describe_type(t))
		if hud.has_method("hint"):
			hud.hint("Nuevos en este nivel:\n" + "\n".join(desc), 6.0)


func _spawn_type(t: String, item: Dictionary, idx: int) -> void:
	var node: Node = null
	match t:
		"ShadowCoin":
			node = _create_instance("ShadowCoin")
			if node:
				node.position = item.get("pos", Vector2(200 + idx * 120, -50))
		"Trampoline":
			node = _create_instance("Trampoline")
			if node:
				node.position = item.get("pos", Vector2(800 + idx * 80, -30))
		"ExplosiveBarrel":
			node = _create_instance("ExplosiveBarrel")
			if node:
				node.position = item.get("pos", Vector2(1400 + idx * 80, -30))
		"ShadowArcher":
			node = _create_instance("ShadowArcher")
			if node:
				node.position = item.get("pos", Vector2(1200 + idx * 180, -40))
		"LavaZone":
			node = _create_instance("LavaZone")
			if node:
				node.position = item.get("pos", Vector2(1100, 0))
				if node.get("size") != null:
					node.set("size", item.get("size", Vector2(600, 80)))
		"WindZone":
			node = _create_instance("WindZone")
			if node:
				node.position = item.get("pos", Vector2(600, -20))
		"Specter":
			node = _create_instance("Specter")
			if node:
				node.position = item.get("pos", Vector2(400 + idx * 220, -40))
		"PlatformShadow":
			node = _create_instance("PlatformShadow")
			if node:
				node.position = Vector2(500 + idx * 240, -80)
		"PressureButton":
			node = _create_instance("PressureButton")
			if node:
				node.position = item.get("pos", Vector2(900, -20))
		"Key":
			node = _create_instance("Key")
			if node:
				node.position = item.get("pos", Vector2(1600, -60))

	if node:
		get_parent().add_child(node)


func _create_instance(type_name: String) -> Node:
	var script_path = "%s%s.gd" % [OBJ_PATH, type_name]
	if not ResourceLoader.exists(script_path):
		return null
	var sc = load(script_path)
	if sc == null:
		return null

	var inst: Node
	if type_name in AREA2D_TYPES:
		inst = Area2D.new()
		var cs = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(48, 48)
		cs.shape = shape
		inst.add_child(cs)
	else:
		inst = Node2D.new()

	inst.set_script(sc)
	return inst


func _describe_type(t: String) -> String:
	var m = {
		"ShadowCoin": "Moneda de sombra: recoge para puntaje.",
		"Trampoline": "Trampolín: salta más alto al pisarlo.",
		"ExplosiveBarrel": "Barril explosivo: explota dañando todo alrededor.",
		"ShadowArcher": "Arquero de sombra: enemigo a distancia que dispara proyectiles.",
		"LavaZone": "Zona de lava: daño continuo al contacto.",
		"WindZone": "Corriente de viento: empuja al jugador.",
		"Specter": "Espectro: enemigo volador que persigue al jugador.",
		"PlatformShadow": "Plataforma de sombra: plataforma móvil oscilante.",
		"PressureButton": "Botón de presión: activa puertas al pisarlo.",
		"Key": "Llave: abre puertas cerradas."
	}
	return m.get(t, t)

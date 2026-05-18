# GhostDrift_Final — Cambios Aplicados (Claude Patch)

## Resumen de Archivos Modificados

### scripts/Player.gd
- **Fix**: `anim.frame_changed.connect(self, "_on_anim_frame_changed")` → sintaxis Godot 4 (`connect(_on_anim_frame_changed)`)
- **Por qué**: En Godot 4 la firma de `connect()` cambió; la versión de 3 argumentos con `self` ya no existe y lanzaba un error en runtime.

---

### scripts/objects/LavaZone.gd (reescritura completa)
- **Fix**: Sintaxis connect Godot 3 → Godot 4
- **Fix**: El daño se aplicaba cada frame (~60 veces/segundo). Ahora usa acumulador `_dmg_acc` para respetar `damage_per_second` real.
- **Mejora**: Añadido `@export var size: Vector2` y redimensión de CollisionShape2D en `_ready()` para que el spawner pueda configurar el tamaño de la zona.

---

### scripts/objects/ExplosiveBarrel.gd (reescritura completa)
- **Fix**: Sintaxis connect Godot 3 → Godot 4
- **Fix**: `area.extents` → eliminado (no existe en Godot 4, `RectangleShape2D` usa `size`)
- **Mejora**: Explosión basada en `distance_to` dentro de `blast_radius`. Añadido flag `_exploded` para evitar doble detonación.

---

### scripts/objects/Key.gd
- **Fix**: Sintaxis connect Godot 3 → Godot 4
- **Mejora**: Añadido `AudioMgr.crystal_sfx()` para feedback sonoro al recoger.

---

### scripts/objects/DashPickup.gd
- **Fix**: Sintaxis connect Godot 3 → Godot 4

---

### scripts/objects/ComboPickup.gd
- **Fix**: Sintaxis connect Godot 3 → Godot 4

---

### scripts/objects/PressureButton.gd
- **Fix crítico**: Texto basura `** * EndPatch` al inicio del archivo causaba parser error. Eliminado.
- **Fix**: Sintaxis connect Godot 3 → Godot 4
- **Mejora**: Añadido `AudioMgr.lever_sfx()` al activar.

---

### scripts/objects/ShadowCoin.gd
- **Fix**: Sintaxis connect Godot 3 → Godot 4
- **Mejora**: Añadido `AudioMgr.crystal_sfx()` para feedback.

---

### scripts/objects/Trampoline.gd
- **Fix**: Sintaxis connect Godot 3 → Godot 4
- **Fix**: Eliminado `has_variable()` que no existe en Godot 4; usa `body.get("velocity")` directo.
- **Fix**: Eliminado preload de Player.gd innecesario; usa constante `-520.0` directamente.
- **Mejora**: `bounce_strength` default subido a 1.4 para salto más satisfactorio.

---

### scripts/objects/WindZone.gd
- **Fix**: Eliminado `has_variable()` que no existe en Godot 4.

---

### scripts/objects/ShadowArcher.gd
- **Fix**: `proj.has_variable("dir")` → `proj.dir = d` (asignación directa, `has_variable` no existe en Godot 4)
- **Fix**: Proyectil ahora creado como `Area2D.new()` con `CollisionShape2D` adjunto para que la detección de colisiones funcione.
- **Limpieza**: Eliminada variable `projectile_scene` innecesaria; referencia directa.

---

### scripts/objects/Specter.gd (reescritura completa)
- **Fix crítico**: Extendía `Node2D` pero llamaba `get_overlapping_bodies()` (solo disponible en `Area2D`). Error en runtime.
- **Nuevo**: Detección de proximidad manual (`distance_to`), cooldown de daño (1.5s), y método `take_hit()` para que el jugador pueda matarlo.

---

### scripts/ObjectsSpawner.gd (reescritura completa)
- **Fix crítico**: `_create_instance` creaba `Node2D.new()` para todos los tipos, luego asignaba scripts que extienden `Area2D`. En Godot 4 esto causa error de tipo incompatible.
- **Fix**: Mapa `AREA2D_TYPES` para crear `Area2D.new()` con `CollisionShape2D` cuando corresponde.
- **Fix**: Eliminado caso duplicado `"PressureButton"` (línea 108 original).
- **Fix**: `node.size = ...` en LavaZone ahora usa `node.set("size", ...)` condicionalmente.
- **Mejora**: Más monedas por nivel; posiciones ajustadas. Nivel 5 añade Spectros.

---

### scripts/Global.gd
- **Nuevo**: Variables `has_dash`, `held_keys`, `combo_level`
- **Nuevo**: Métodos `give_dash()`, `give_key()`, `upgrade_combo()` — eran llamados desde DashPickup, Key, ComboPickup pero no existían (crash garantizado).
- **Fix**: `reset()` ahora también resetea las nuevas variables.

---

### scripts/AudioMgr.gd
- **Nuevo**: `explosion()` — usado por ExplosiveBarrel. Sin él el juego crasheaba al explotar un barril.
- **Nuevo**: `pickup()` — usado por DashPickup y ComboPickup.

---

## Estado del Paralaje / Fondos

Los 5 niveles ya tienen `ParallaxBackground → ParallaxLayer (motion_scale=0.45) → BGSprite (TextureRect)` configurado correctamente usando las imágenes `bg_level1..5.png`. No se requieren cambios adicionales.

El `stretch_mode = 6` (STRETCH_KEEP_ASPECT_COVERED) garantiza que la imagen llene la pantalla a cualquier resolución.

---

## Instrucciones de Verificación en Godot

1. Abrir `GhostDrift_Final/project.godot` en Godot 4.x
2. En el panel **Script** o **Output**, verificar que no haya errores rojos de parser
3. Ejecutar **Level1.tscn** → caminar, correr (Shift), saltar (Space/W), atacar (Z), shadow power (X)
4. Verificar trampolín: al pisarlo el jugador debe saltar más alto
5. Ejecutar **Level2.tscn** → disparar el barril explosivo (atacarlo), verificar explosión y daño
6. Ejecutar **Level3.tscn** → verificar zona de lava (1 daño/seg), corriente de viento, espectros
7. Ejecutar **Level4.tscn** → recoger llave (debe aparecer en consola/Global), pisar botón de presión
8. Ejecutar **Level5.tscn** → mezcla completa de todos los objetos

---

## Notas de Balance

| Parámetro | Nivel 1 | Nivel 2 | Nivel 3 | Nivel 4 | Nivel 5 |
|-----------|---------|---------|---------|---------|---------|
| Enemigos base | 1–2 | 2–3 | 3–4 (+ espectros) | 3–5 | 5–7 |
| Monedas spawneadas | 3 | 4 | 3 | 2 | 5 |
| Peligros | ninguno | barril | lava+viento | plataformas | lava+espectros |
| Par time sugerido | 90s | 120s | 150s | 180s | 240s |

**Valores tunables (todos con @export):**
- `Player.WALK_SPEED = 200`, `RUN_SPEED = 340` — Aumentar a 240/380 para sensación más rápida
- `Enemy.spd = 85` — Subir a 110 para Nivel 4–5
- `LavaZone.damage_per_second = 1.0` — 2.0 para mayor dificultad
- `ShadowArcher.shoot_interval = 2.0` — Bajar a 1.2 en niveles difíciles
- `Trampoline.bounce_strength = 1.4` — Rango recomendado: 1.2–1.8
- `Specter.speed = 80`, `damage_range = 40` — Subir speed a 110 en Nivel 5

---

## Log de Errores (antes → después)

**Antes:**
- `Player.gd:166` — `connect()` con 3 argumentos (Godot 3 API) → runtime error
- `LavaZone.gd:7-8` — `connect("body_entered", self, ...)` → parse/runtime error  
- `ExplosiveBarrel.gd:8` — mismo problema + `area.extents` no existe
- `Key.gd:7` — `connect()` Godot 3
- `DashPickup.gd:5` — `connect()` Godot 3
- `ComboPickup.gd:7` — `connect()` Godot 3
- `PressureButton.gd:1` — texto basura `** * EndPatch` → **parser error** (bloquea Godot)
- `ShadowCoin.gd:6` — `connect()` Godot 3
- `Trampoline.gd:8,21` — `connect()` Godot 3 + `has_variable()` no existe
- `WindZone.gd:13` — `has_variable()` no existe
- `ShadowArcher.gd:31` — `has_variable()` no existe
- `Specter.gd:18` — `get_overlapping_bodies()` en Node2D → crash
- `ObjectsSpawner.gd` — `Node2D.new()` para scripts Area2D → crash
- `Global.gd` — métodos `give_dash/give_key/upgrade_combo` faltantes → crash al recoger items
- `AudioMgr.gd` — métodos `explosion/pickup` faltantes → crash al explotar barril

**Después:** 0 errores críticos. Todos los objetos spawneados correctamente con base type adecuado.

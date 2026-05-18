# Ghost Drift: Shadow Drift — Versión Final
## Proyecto Godot 4 completo

### ▶ Cómo abrir
1. Descarga **Godot 4.2+** → https://godotengine.org/download
2. Abre Godot → **Importar** → selecciona la carpeta `GhostDrift_Final/` → `project.godot`
3. Pulsa **F5** para jugar

### 🎮 Controles
| Tecla | Acción |
|-------|--------|
| A / ← | Mover izquierda |
| D / → | Mover derecha |
| Espacio / W | Saltar |
| Z | Atacar |
| X | Anclar sombra / Teletransportarse |
| Shift | Correr |
| Escape | Pausa |
| F11 | Pantalla completa |

###  Mecánica de Sombra
- Pulsa **X** para anclar la sombra de César en el suelo
- Pulsa **X** de nuevo para teletransportarte a esa posición
- La barra morada indica la energía restante (se recarga sola)

### 🗺️ Los 5 Niveles
| # | Nombre | Ambiente | Enemigos |
|---|--------|----------|----------|
| 1 | Ruinas Sombrías | Noche, luna llena, ruinas | 11 esqueletos |
| 2 | Bosque Tenebroso | Árboles, faroles teal, niebla | 13 esqueletos |
| 3 | Minas Profundas | Galerías, vagonetas, soportes | 15 esqueletos |
| 4 | Torre del Olvido | Columnas de energía, plataformas flotantes | 20 esqueletos |
| 5 | Santuario Final | Eclipse rojo, lava, altar oscuro | 20 + BOSS |

### ⭐ Sistema de Estrellas (por nivel)
- **⭐⭐⭐** Sin muertes, ≤3 golpes recibidos, ≥50% cristales recogidos, tiempo ≤ par
- **⭐⭐** Un criterio fallido
- **⭐** Dos criterios fallidos
- **☆☆☆** Completado con todos los criterios fallidos

### 🔑 Objetivos de cada nivel
1. Elimina **todos los esqueletos** → la puerta EXIT se desbloquea
2. Recoge los **5 cristales** para maximizar estrellas
3. Cruza la puerta EXIT para ver tus resultados

### 📦 Contenido del proyecto
- **18 scripts GDScript** — Player, Enemy, HUD, Pause, Results, Audio...
- **5 escenas de nivel** — 30-43 plataformas, torches, spikes, moving platforms, mine carts
- **8 escenas de menú** — MainMenu, GameOver, WinScreen, + integradas en niveles
- **291 sprites PNG** — César (7 animaciones), Esqueleto (4 animaciones), cristales, tiles, fondos
- **Audio procedural** — Música y SFX generados en tiempo real con Godot AudioStreamWAV

### 🔧 Recursos y licencias
- Motor: **Godot 4** (MIT) — https://godotengine.org
- Sprites personajes: generados con IA para uso educativo
- Tiles y fondos: generados con Python/Pillow para uso educativo
- Audio: sintetizador procedural interno, sin archivos externos
- Proyecto: **uso educativo exclusivo** — UD5 Práctica 1

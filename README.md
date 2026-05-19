# Ghost Drift: Shadow Drift — Versión Final

## Proyecto Godot 4 completo

### ▶ Cómo abrir

1. Descarga **Godot 4.2+** → https://godotengine.org/download
2. Abre Godot → **Importar** → selecciona la carpeta `GhostDrift_Final/` → `project.godot`
3. Pulsa **F5** para jugar

### 🎮 Controles

| Tecla       | Acción                            |
| ----------- | --------------------------------- |
| A / ←       | Mover izquierda                   |
| D / →       | Mover derecha                     |
| Espacio / W | Saltar                            |
| Z           | Atacar                            |
| X           | Anclar sombra / Teletransportarse |
| Shift       | Correr                            |
| Escape      | Pausa                             |
| F11         | Pantalla completa                 |

### 🗺️ Los 5 Niveles

| #   | Nombre           | Ambiente                                   | Enemigos      |
| --- | ---------------- | ------------------------------------------ | ------------- |
| 1   | Ruinas Sombrías  | Noche, luna llena, ruinas                  | 11 esqueletos |
| 2   | Bosque Tenebroso | Árboles, faroles teal, niebla              | 13 esqueletos |
| 3   | Minas Profundas  | Galerías, vagonetas, soportes              | 15 esqueletos |
| 4   | Torre del Olvido | Columnas de energía, plataformas flotantes | 20 esqueletos |
| 5   | Santuario Final  | Eclipse rojo, lava, altar oscuro           | 20 + BOSS     |

### ⭐ Sistema de Estrellas (por nivel)

- **⭐⭐⭐** Sin muertes, ≤3 golpes recibidos, ≥50% cristales recogidos, tiempo ≤ par
- **⭐⭐** Un criterio fallido
- **⭐** Dos criterios fallidos
- **☆☆☆** Completado con todos los criterios fallidos

### 🔑 Objetivos de cada nivel

1. Recoge **todos los cristales** del nivel
2. Elimina al menos los **enemigos requeridos** del nivel
3. Cruza la puerta EXIT para ver tus resultados y avanzar
4. Al superar el nivel 5 aparece la pantalla de victoria y se guarda tu puntuación en el ranking

### ⚔️ Requisito de enemigos

- El mínimo empieza en **4** y sube **1 por nivel**
- El objetivo se ajusta al número de enemigos disponibles en cada escena para no bloquear el progreso

### 📦 Contenido del proyecto

- **18 scripts GDScript** — Player, Enemy, HUD, Pause, Results, Audio...
- **5 escenas de nivel** — 30-43 plataformas, torches, spikes, moving platforms, mine carts
- **8 escenas de menú** — MainMenu, GameOver, WinScreen, + integradas en niveles
- **291 sprites PNG** — César (7 animaciones), Esqueleto (4 animaciones), cristales, tiles, fondos
- **Audio procedural** — Música y SFX generados en tiempo real con Godot AudioStreamWAV

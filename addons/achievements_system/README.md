# Achievement System — Godot Plugin

Achievement system for Godot 4 projects.  
Supports **simple** (one-shot) and **cumulative** (incremental) achievements,  
animated pop-up notifications, and automatic JSON save/load.

---

## Installation

1. Copy the `addons/achievement_system/` folder into your project's `addons/` directory.
2. In Godot, go to **Project → Project Settings → Plugins** and enable **Achievement System**.  
   This automatically registers `AchievementsManager` as a global autoload.
3. Add `achievement_notification.tscn` as a child of your main/root scene  
   (or any persistent scene that lives throughout gameplay).

---

## Creating Achievements

1. In the FileSystem panel, right-click a folder → **New Resource** → select `Achievement`.
2. Fill in the fields:

| Field | Description |
|---|---|
| `id` | Unique string identifier (e.g. `"first_delivery"`) |
| `achievement_name` | Display name |
| `description` | Short description |
| `unlocked_icon` | Texture shown when unlocked |
| `locked_icon` | Texture shown when locked |
| `is_cumulative` | Enable for multi-step achievements |
| `max_progress` | Number of steps required (only when `is_cumulative = true`) |

3. Open the `AchievementsManager` autoload scene  
   (`addons/achievement_system/scenes/achievement_manager.tscn`)  
   and drag your `.tres` files into the **Achievements Files** array.

---

## API

```gdscript
# Unlock a simple achievement
AchievementsManager.unlock("first_delivery")

# Increment a cumulative achievement (e.g. "find 3 keys")
AchievementsManager.increment("find_keys")   # call this once per key found

# Query state
AchievementsManager.is_unlocked("first_delivery")   # → bool
AchievementsManager.get_progress("find_keys")        # → int (current steps)
AchievementsManager.get_max_progress("find_keys")    # → int (target steps)
```

### Signals (on `AchievementsManager`)

```gdscript
# Emitted when an achievement is fully unlocked.
signal achievement_unlocked(achievement_data: Achievement)

# Emitted on each increment of a cumulative achievement (before the final one).
signal achievement_progress(achievement_data: Achievement, current: int, max_val: int)
```

---

## Pop-up Notifications

The `AchievementNotification` CanvasLayer listens to the signals above automatically.

- **Simple unlock** → shows a "ACHIEVEMENT UNLOCKED" banner.
- **Cumulative progress** → shows the cell with the circular progress bar overlaid on the icon.
- **Cumulative final step** → treated as a full unlock banner.

**Optional sound:** assign an `AudioStream` to the `unlock_sound` export in the Inspector.

---

## Building an Achievements Menu

The plugin does not include a full menu UI (it's project-specific). Use `AchievementCell` directly:

```gdscript
const ACHIEVEMENT_CELL = preload("res://addons/achievement_system/scenes/achievement_cell.tscn")

func populate_list(container: VBoxContainer) -> void:
	for achievement in AchievementsManager.all_achievements.values():
		var cell: PanelContainer = ACHIEVEMENT_CELL.instantiate()
		var unlocked := AchievementsManager.is_unlocked(achievement.id)
		var current  := AchievementsManager.get_progress(achievement.id)
		var maximum  := AchievementsManager.get_max_progress(achievement.id)
		cell.setup(achievement, unlocked, false, current, maximum)
		container.add_child(cell)
```

---

## Styling

The cell ships with a dark panel + gold border as defaults.  
Override by:
- Editing the `StyleBoxFlat` sub-resources inside `achievement_cell.tscn`.
- Applying a Godot `Theme` resource to the cell or its parent.
- Configuring `CircularProgressBar` exports (`fill_color`, `background_color`, `arc_width`) in the Inspector.

---

## Save File

Progress is stored at `user://achievements.json`.  
The format is:

```json
{
  "unlocked": ["first_delivery", "no_deaths"],
  "progress": { "find_keys": 2 }
}
```

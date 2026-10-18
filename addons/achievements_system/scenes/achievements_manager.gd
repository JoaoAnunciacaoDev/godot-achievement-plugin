extends Node

signal achievement_unlocked(achievement_data: Achievement)
signal achievement_progress(achievement_data: Achievement, current: int, max_val: int)

const SAVE_FILE_PATH : String = "user://achievements.json"

@export_dir var achievements_folder: String = "res://resources/achievements/"
@export var achievements_files: Array[Achievement]

var all_achievements: Dictionary = {}
var unlocked_ids: Array[String] = []
var _progress: Dictionary = {}

func _ready() -> void:
	_load_achievements_from_folder(achievements_folder)
	_load_all_achievement_resources()
	load_progress()

func _load_achievements_from_folder(folder_path: String) -> void:
	if folder_path.is_empty() or not DirAccess.dir_exists_absolute(folder_path):
		return
	
	var dir := DirAccess.open(folder_path)
	if not dir:
		printerr("AchievementsManager: não foi possível abrir a pasta '%s'." % folder_path)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			var clean_name : String = file_name.trim_suffix(".remap")
			if clean_name.ends_with(".tres") or clean_name.ends_with(".res"):
				var full_path := folder_path.path_join(clean_name)
				var resource = load(full_path)
				
				if resource is Achievement:
					register_achievement(resource)
		
		file_name = dir.get_next()

func register_achievement(achievement: Achievement) -> void:
	if achievement and not achievement.id.is_empty():
		all_achievements[achievement.id] = achievement
		achievements_files.append(achievement)

func unlock(id: String) -> void:
	if not all_achievements.has(id):
		push_warning("AchievementsManager: unknown achievement id '%s'." % id)
		return
	
	if is_unlocked(id):
		return
	
	unlocked_ids.append(id)
	achievement_unlocked.emit(all_achievements[id])
	save_progress()

func increment(id: String) -> void:
	if not all_achievements.has(id):
		push_warning("AchievementsManager: unknown achievement id '%s'." % id)
		return
	
	var achievement: Achievement = all_achievements[id]
	
	if not achievement.is_cumulative:
		push_warning(
			"AchievementsManager: '%s' is not cumulative. Use unlock() instead." % id
			)
		return
	
	if is_unlocked(id):
		return
	
	var current: int = _progress.get(id, 0) + 1
	_progress[id] = current
	
	if current >= achievement.max_progress:
		unlocked_ids.append(id)
		achievement_unlocked.emit(achievement)
	else:
		achievement_progress.emit(achievement, current, achievement.max_progress)
	
	save_progress()

func is_unlocked(id: String) -> bool:
	return id in unlocked_ids

func get_progress(id: String) -> int:
	return _progress.get(id, 0)

func get_max_progress(id: String) -> int:
	if all_achievements.has(id):
		return all_achievements[id].max_progress
	return 1

func reset_all() -> void:
	unlocked_ids.clear()
	_progress.clear()
	save_progress()

func save_progress() -> void:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		printerr("AchievementsManager: failed to write save file at '%s'." % SAVE_FILE_PATH)
		return
	
	var data := {
		"unlocked": unlocked_ids,
		"progress": _progress,
	}
	file.store_string(JSON.stringify(data))
	file.close()

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		printerr("AchievementsManager: failed to read save file at '%s'." % SAVE_FILE_PATH)
		return
	
	var content : String = file.get_as_text()
	file.close()
	
	if content.is_empty():
		return
	
	var parsed = JSON.parse_string(content)
	if parsed == null:
		printerr("AchievementsManager: save file is corrupted.")
		return
	
	if typeof(parsed) == TYPE_ARRAY:
		_import_legacy_format(parsed)
		return
	
	if typeof(parsed) == TYPE_DICTIONARY:
		if parsed.has("unlocked") and typeof(parsed["unlocked"]) == TYPE_ARRAY:
			var ids: Array[String] = []
			for item in parsed["unlocked"]:
				if typeof(item) == TYPE_STRING:
					ids.append(item)
			unlocked_ids = ids

		if parsed.has("progress") and typeof(parsed["progress"]) == TYPE_DICTIONARY:
			_progress = parsed["progress"]
	else:
		printerr("AchievementsManager: unrecognized save format.")

func _import_legacy_format(arr: Array) -> void:
	var ids: Array[String] = []
	for item in arr:
		if typeof(item) == TYPE_STRING:
			ids.append(item)
	unlocked_ids = ids
	save_progress()
	print("AchievementsManager: legacy save migrated to new format.")

func _load_all_achievement_resources() -> void:
	for achievement in achievements_files:
		if achievement:
			all_achievements[achievement.id] = achievement

@tool
extends EditorPlugin

const MANAGER_AUTOLOAD_NAME : String = "AchievementsManager"
const MANAGER_PATH : String = "res://addons/achievements_system/scenes/achievement_manager.tscn"

const NOTIF_AUTOLOAD_NAME : String = "AchievementNotification"
const NOTIF_PATH : String = "res://addons/achievements_system/scenes/achievement_notification.tscn"

func _enable_plugin() -> void:
	add_autoload_singleton(MANAGER_AUTOLOAD_NAME, MANAGER_PATH)
	add_autoload_singleton(NOTIF_AUTOLOAD_NAME, NOTIF_PATH)

func _disable_plugin() -> void:
	remove_autoload_singleton(NOTIF_AUTOLOAD_NAME)
	remove_autoload_singleton(MANAGER_AUTOLOAD_NAME)

extends Control

func _on_first_achievement_button_pressed() -> void:
	AchievementsManager.unlock(AchievementIDs.FIRST_ACHIEVE)

func _on_second_achievement_button_pressed() -> void:
	AchievementsManager.unlock(AchievementIDs.SECOND_ACHIEVE)

func _on_cumulative_achievement_button_3_pressed() -> void:
	AchievementsManager.increment(AchievementIDs.OUR_LITTLE_SECRET)

func _on_reset_button_pressed() -> void:
	AchievementsManager.reset_all()

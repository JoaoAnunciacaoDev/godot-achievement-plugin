extends PanelContainer
class_name AchievementsMenu

@export var cell : PackedScene
@export var container : VBoxContainer

func _ready() -> void:
	hide()
	
	populate_achievements_menu()

func populate_achievements_menu() -> void:
	for child in container.get_children():
		child.queue_free()
	
	for achievement in AchievementsManager.achievements_files:
		var cell_instance = cell.instantiate()
		
		var is_unlocked: bool = AchievementsManager.is_unlocked(achievement.id)
		var current_prog: int = AchievementsManager.get_progress(achievement.id)
		var max_prog: int = AchievementsManager.get_max_progress(achievement.id)
		
		cell_instance.setup(
			achievement,
			is_unlocked,
			false,
			current_prog,
			max_prog
		)
		
		container.add_child(cell_instance)

func _on_back_button_pressed() -> void:
	hide()

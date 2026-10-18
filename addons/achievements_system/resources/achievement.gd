extends Resource
class_name Achievement

@export var id: String = ""
@export var achievement_name: String = "New Achievement"
@export var description: String = "Achievement description"
@export var unlocked_icon: Texture2D
@export var locked_icon: Texture2D
@export var is_cumulative: bool = false
@export_range(2, 999, 1) var max_progress: int = 2

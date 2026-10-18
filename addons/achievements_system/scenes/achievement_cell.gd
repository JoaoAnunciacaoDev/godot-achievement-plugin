extends PanelContainer
class_name AchievementCell

signal time_screen_over(cell: PanelContainer)

@export var icon: TextureRect
@export var title_label: Label
@export var description_label: Label
@export var unlock_label: Label
@export var progress_bar: TextureProgressBar
@export var notification_timer: Timer

@export_range(1.0, 10.0, 0.25) var notification_duration: float = 4.0

var _is_notification: bool = false

func setup(
	achievement  : Achievement, is_unlocked  : bool, notification : bool = false,
	current_prog : int = -1, max_prog : int = -1,) -> void:
	
	_is_notification = notification
	
	if is_unlocked:
		icon.texture = achievement.unlocked_icon
		title_label.text = achievement.achievement_name
		description_label.text = achievement.description
		
		unlock_label.text = "ACHIEVEMENT UNLOCKED"
		unlock_label.visible = notification
		
	else:
		icon.texture = achievement.locked_icon
		
		if achievement.is_secret:
			title_label.text = "???"
			description_label.text = achievement.secret_description
			unlock_label.visible = false
		
		else:
			title_label.text = achievement.achievement_name
			description_label.text = achievement.description
			
			if achievement.is_cumulative and current_prog >= 0:
				unlock_label.text = "PROGRESS: %d / %d" % [current_prog, max_prog]
				unlock_label.visible = true
			else:
				unlock_label.visible = false
	
	if progress_bar:
		var show : bool = (
			achievement.is_cumulative and not is_unlocked and current_prog >= 0
		)
		progress_bar.visible = show
		if show:
			progress_bar.max_value = max_prog
			progress_bar.value = current_prog

func _ready() -> void:
	if not _is_notification: return
	
	scale = Vector2(0.75, 0.75)
	modulate.a   = 0.0
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(
		self, "scale", Vector2.ONE, 0.32
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(
		self, "modulate:a", 1.0, 0.16
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(
		func():
			notification_timer.start(notification_duration)
			)

func _on_timer_timeout() -> void:
	time_screen_over.emit(self)

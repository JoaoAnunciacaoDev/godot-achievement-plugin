extends CanvasLayer

@export var unlock_sound: AudioStream
@export var vbox: VBoxContainer

const ACHIEVEMENT_CELL: PackedScene = preload(
	"res://addons/achievements_system/scenes/achievement_cell.tscn"
)

var _pending: Array[Dictionary] = []
var _is_showing: bool = false

func _ready() -> void:
	AchievementsManager.achievement_unlocked.connect(_on_achievement_unlocked)
	AchievementsManager.achievement_progress.connect(_on_achievement_progress)
	vbox.hide()
	hide()

func _on_achievement_unlocked(data: Achievement) -> void:
	_enqueue(data, -1, -1)

func _on_achievement_progress(data: Achievement, current: int, max_val: int) -> void:
	_enqueue(data, current, max_val)

func show_preview(data: Achievement, current := -1, max_val := -1) -> void:
	_enqueue(data, current, max_val)

func _enqueue(data: Achievement, current: int, max_val: int) -> void:
	_pending.append({ "data": data, "current": current, "max": max_val })
	if not _is_showing:
		_show_next()

func _show_next() -> void:
	if _pending.is_empty():
		_is_showing = false
		vbox.hide()
		hide()
		return

	_is_showing = true
	show()
	vbox.show()

	var entry : Dictionary = _pending.pop_front()
	var data : Achievement = entry["data"]
	var current : int = entry["current"]
	var max_val : int = entry["max"]
	var is_full : bool = (current == -1)
	
	var cell: PanelContainer = ACHIEVEMENT_CELL.instantiate()
	cell.setup(data, is_full, true, current, max_val)
	cell.time_screen_over.connect(_on_cell_timer_over)
	vbox.add_child(cell)
	
	_play_sound()

func _on_cell_timer_over(cell: PanelContainer) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(cell, "modulate:a", 0.0, 0.18) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(cell, "scale", Vector2(0.88, 0.88), 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(
		func():
			cell.queue_free()
			)
	
	_show_next()

func _play_sound() -> void:
	if not unlock_sound: return
	
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = unlock_sound
	player.autoplay = true
	add_child(player)
	
	player.finished.connect(player.queue_free)

extends CanvasLayer

@export var unlock_sound: AudioStream
@export var vbox: VBoxContainer
@export var max_concurrent: int = 3
@export var audio_bus: StringName

const ACHIEVEMENT_CELL: PackedScene = preload(
	"res://addons/achievements_system/scenes/achievement_cell.tscn"
)

var _active_count: int = 0
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
	_process_queue()

func _process_queue() -> void:
	while not _pending.is_empty() and _active_count < max_concurrent:
		_show_item(_pending.pop_front())

func _show_item(entry: Dictionary) -> void:
	_active_count += 1
	show()
	vbox.show()
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
	tween.tween_property(cell, "modulate:a", 0.0, 0.15) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(cell, "scale", Vector2(0.88, 0.88), 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.finished.connect(
		func():
			cell.queue_free()
			_active_count -= 1
			if _active_count <= 0 and _pending.is_empty():
				_active_count = 0
				vbox.hide()
				hide()
			else:
				_process_queue()
			)

func _play_sound() -> void:
	if not unlock_sound: return
	
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = unlock_sound
	player.autoplay = true
	player.bus = audio_bus
	add_child(player)
	
	player.finished.connect(player.queue_free)

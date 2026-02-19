class_name Clock extends Node

signal midnight(clock: Clock)
signal time_changed(clock: Clock)

@export var length_of_day: float = 15

var time_scale: float = 1.0:
	set(value):
		time_scale = value
		_time_diff = calculate_time_diff()

@export var hours: int = 0
@export var minutes: int = 0

@export_group("Custom Timescale")
@export var hours_in_day: int = 24
@export var minutes_in_hour: int = 60

func _ready() -> void:
	Daytimer.logger.info("minutes in day %s" % total_minutes_in_day())
	_time_diff = calculate_time_diff()

var _elapsed: float = 0.0
var _time_diff: float
var _count: int = 0

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed > _time_diff:
		_count += 1
		_elapsed = 0.0
		tick()

func calculate_time_diff() -> float:
	return 60.0 / time_scale

func total_minutes_in_day() -> int:
	return hours_in_day * minutes_in_hour

func time_scale_for_real_minutes(real_minutes: float) -> float:
	return total_minutes_in_day() / (real_minutes * 60.0)

func tick() -> void:
	minutes += 1
	if minutes >= minutes_in_hour:
		hours += 1
		minutes = 0
	if hours >= hours_in_day:
		midnight.emit(self)
		hours = 0
	time_changed.emit(self)
	return


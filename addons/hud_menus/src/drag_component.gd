class_name DragComponent extends Node

@export var _controlling: Control
@export var _handle_control: Control

func _ready() -> void:
	_subscribe()

func _process(delta: float) -> void:
	if _is_being_dragged: print("drag target: %s" % _drag_target)
	if _is_being_dragged or _controlling.position.distance_to(_drag_target) > 1.0:
		if _is_being_dragged:
			_handle_drag()
			_update_drag_target()
		_controlling.position = _controlling.position.lerp(_drag_target, 1.0 - exp(-_follow_speed * delta))
		
func _input(event: InputEvent) -> void:
	if !_can_drag: return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _handle_hovered:
				_start_drag()
		else: 
			if event.button_index == MOUSE_BUTTON_LEFT:
				if _is_being_dragged:
					_end_drag()

func _subscribe() -> void:
	_handle_control.mouse_entered.connect(_on_handle_area_mouse_entered)
	_handle_control.mouse_exited.connect(_on_handle_area_mouse_exited)

var _handle_hovered: bool = false

func _on_handle_area_mouse_entered() -> void:
	_handle_hovered = true
	print("controlling hovered: true")

func _on_handle_area_mouse_exited() -> void:
	_handle_hovered = false
	print("controlling hovered: false")

@export_category("Drag Settings")

signal drag_started()
signal drag_ended()

@export var _can_drag: bool = true
@export_range(1.0, 50.0) var _follow_speed: float = 40.0
@export var _restrict_to_parent_bounds: bool = true

var _is_being_dragged: bool = false
@onready var _drag_offset: Vector2 = Vector2.ZERO
@onready var _drag_target: Vector2 = _controlling.position

func _start_drag() -> void:
	print("starting drag")
	_on_drag_start()
	drag_started.emit()
	_is_being_dragged = true
	_drag_offset = _controlling.get_local_mouse_position()

func _handle_drag() -> void:
	_on_drag()
	return

func _end_drag() -> void:
	print("stopping drag")
	_on_drag_end()
	drag_ended.emit()
	_is_being_dragged = false

func _update_drag_target() -> void:
	var raw := _controlling.get_parent_control().get_local_mouse_position() - _drag_offset
	if not _restrict_to_parent_bounds:
		_drag_target = raw
		return
	_drag_target = _clamp_to_valid_bounds(raw)

func _clamp_to_valid_bounds(target: Vector2) -> Vector2:
	var parent_size := _controlling.get_parent_control().size
	var handle_offset := _handle_control.get_global_rect().position - _controlling.get_global_rect().position
	var min_pos := -handle_offset
	var max_pos := parent_size - handle_offset - _handle_control.size
	return target.clamp(min_pos, max_pos)

func _can_drop() -> bool:
	push_error("Not implemented")
	return true

func _on_drag_start() -> void:
	return

func _on_drag() -> void:
	return

func _on_drag_end() -> void:
	return

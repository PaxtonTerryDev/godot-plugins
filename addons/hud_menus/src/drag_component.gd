class_name DragComponent extends Node

static func create(controlling: Control, handle_control: Control, bounded_to: Control = controlling) -> DragComponent:
	var n = DragComponent.new()
	n._controlling = controlling
	n._handle_control = handle_control
	n._bounded_to = bounded_to
	return n

@export var _controlling: Control
@export var _handle_control: Control
@export var _bounded_to: Control

func _ready() -> void:
	if _bounded_to == null:
		_bounded_to = _controlling.get_parent_control()
	_subscribe()
	_resolver = _create_resolver()

func _process(delta: float) -> void:
	if _is_being_dragged or _controlling.position.distance_to(_drag_target) > 1.0:
		if _is_being_dragged:
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

func _on_handle_area_mouse_exited() -> void:
	_handle_hovered = false

@export_category("Drag Settings")

signal drag_started()
signal drag_ended()

@export var _can_drag: bool = true
@export_range(1.0, 50.0) var _follow_speed: float = 40.0

enum BoundBehavior {
	NONE,
	RESTRICT,
	RETURN
}

const DEFAULT_BOUND_BEHAVIOR = BoundBehavior.RETURN

@export var bound_behavior: BoundBehavior = DEFAULT_BOUND_BEHAVIOR:
	set(value):
		bound_behavior = value
		_resolver = _create_resolver()


var _is_being_dragged: bool = false
@onready var _drag_offset: Vector2 = Vector2.ZERO
@onready var _drag_target: Vector2 = _controlling.position

var _resolver: DragResolver

func _create_resolver() -> DragResolver:
	match bound_behavior:
		BoundBehavior.NONE:
			return DragResolver.new(_controlling, _handle_control, _bounded_to)
		BoundBehavior.RESTRICT:
			return RestrictResolver.new(_controlling, _handle_control, _bounded_to)
		BoundBehavior.RETURN:
			return ReturnResolver.new(_controlling, _handle_control, _bounded_to)
		_:
			return null

func _start_drag() -> void:
	drag_started.emit()
	_is_being_dragged = true
	_drag_offset = _controlling.get_local_mouse_position()

func _end_drag() -> void:
	drag_ended.emit()
	_drag_target = _resolver.resolve_release()
	_is_being_dragged = false

func _update_drag_target() -> void:
	var raw := _controlling.get_parent_control().get_local_mouse_position() - _drag_offset
	_drag_target = _resolver.resolve_drag(raw)

# ----------------------------------------------------------
# Resolvers
# ----------------------------------------------------------

class DragResolver:
	var _controlling: Control
	var _handle: Control
	var _bounded_to: Control

	func _init(controlling: Control, handle: Control, bounded_to: Control) -> void:
		_controlling = controlling
		_handle = handle
		_bounded_to = bounded_to

	func resolve_drag(raw: Vector2) -> Vector2:
		return raw

	func resolve_release() -> Vector2:
		return _controlling.position

	func _clamp_to_valid_bounds(target: Vector2) -> Vector2:
		var parent_global := _controlling.get_parent_control().get_global_rect().position
		var handle_offset := _handle.get_global_rect().position - _controlling.get_global_rect().position
		var bounded_global := _bounded_to.get_global_rect().position
		var min_pos := bounded_global - parent_global - handle_offset
		var max_pos := min_pos + _bounded_to.size - _handle.size
		return target.clamp(min_pos, max_pos)
	
class RestrictResolver extends DragResolver:
	func resolve_drag(raw: Vector2) -> Vector2:
		return _clamp_to_valid_bounds(raw)

class ReturnResolver extends DragResolver:
	var _last_valid: Vector2

	func _init(controlling: Control, handle: Control, bounded_to: Control) -> void:
		super(controlling, handle, bounded_to)
		_last_valid = controlling.position


	func resolve_drag(raw: Vector2) -> Vector2:
		_last_valid = _clamp_to_valid_bounds(raw)
		return raw

	func resolve_release() -> Vector2:
		return _last_valid

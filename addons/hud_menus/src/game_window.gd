class_name GameWindow extends Control

@export_group("Internal Components")
@export var _top_bar: PanelContainer 
@export_group("Drag", "_drag_")
@export var _drag_component: DragComponent 
@export var _drag_active: bool = true
@export_range(0.0, 50.0) var _drag_follow_speed: float = 40.0
@export var _drag_bounded_to: Control:
	set(value):
		_drag_bounded_to = value
		_drag_component._bounded_to = _drag_bounded_to

func _ready() -> void:
	_drag_component._bounded_to = _drag_bounded_to

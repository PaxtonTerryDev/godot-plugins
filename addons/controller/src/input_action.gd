class_name InputAction extends Resource

enum Type {
	POLL,
	EVENT
}

signal pressed()
signal released()
signal held()

@export var _action: StringName
@export var _type: Type = Type.EVENT
var _down: bool = false

func reset() -> void:
	_down = false

func exec() -> void:
	if Input.is_action_just_pressed(_action): 
		pressed.emit()
		_down = true
	if _down:
		held.emit()
	if Input.is_action_just_released(_action):
		released.emit()
		_down = false


static func create(action: StringName, type: Type = Type.EVENT) -> InputAction:
	var ia = InputAction.new()
	ia._action = action
	ia._type = type
	return ia

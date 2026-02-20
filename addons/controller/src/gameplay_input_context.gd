class_name GameplayInputContext extends InputContext

var move_up: InputAction = InputAction.create("move_up")
var move_right: InputAction = InputAction.create("move_right")
var move_down: InputAction = InputAction.create("move_down")
var move_left: InputAction = InputAction.create("move_left")

func get_actions() -> Array[InputAction]:
	return [
		move_up,
		move_right,
		move_down,
		move_left,
		]


## Used to enable drag and drop functionality of menu items
class_name HUDMenuHandle extends RefCounted

var _area: Control
var _controlling_hovered: bool = false

func _init(area: Control) -> void:
	_area = area
	_subscribe()

func _subscribe() -> void:
	_area.mouse_entered.connect(_on_handle_area_mouse_entered)
	_area.mouse_exited.connect(_on_handle_area_mouse_exited)

func _on_handle_area_mouse_entered() -> void:
	_controlling_hovered = true
	print("controlling hovered: true")

func _on_handle_area_mouse_exited() -> void:
	_controlling_hovered = false
	print("controlling hovered: false")

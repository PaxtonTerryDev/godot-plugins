@tool
extends EditorPlugin

const autoload: Dictionary = {
	"name": "Database",
	"path": "res://addons/database_access_layer/scenes/database.tscn"
	}

func _enable_plugin() -> void:
	add_autoload_singleton(autoload.name, autoload.path)


func _disable_plugin() -> void:
	remove_autoload_singleton(autoload.name)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

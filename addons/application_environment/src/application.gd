extends Node

var logger = Syslog.new(["Application"])

func _ready() -> void:
	logger.info("ready - current environment: %s" % env())
	logger.info("current data directory: %s " % get_data_dir_path())
	_ensure_directories()

func is_dev() -> bool:
	return OS.has_feature("editor")

func env() -> String:
	return "development" if is_dev() else "production"

const DEV_DATA_DIR: String = "res://tmp/data"
const PROD_DATA_DIR: String = "user://"

func get_data_dir_path() -> String:
	return DEV_DATA_DIR if is_dev() else PROD_DATA_DIR

func _ensure_directories() -> void:
	logger.info("ensuring existence of data directories")
	DirAccess.make_dir_recursive_absolute(get_data_dir_path())



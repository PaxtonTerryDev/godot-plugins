extends Node

var logger = Syslog.new(["Database"])
var db: SQLite = null

func _ready() -> void:
	_ensure_connection()

func _get_db_path() -> String:
	var base_path = Application.get_data_dir_path()
	return base_path.path_join("data")

func _ensure_connection() -> void:
	logger.info("verifying sqlite connection")
	db = SQLite.new()
	db.path = _get_db_path()
	db.verbosity_level = SQLite.VERBOSE
	db.open_db()
	db.close_db()

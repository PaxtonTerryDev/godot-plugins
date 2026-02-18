extends Node

# Just some general notes - 
# all core tables are prefixed with "core_*"
# this differentiates them from mod tables.

var logger = Syslog.new(["Database"])

enum Verbosity {
	QUIET = 0,
	NORMAL = 1,
	VERBOSE = 2,
	VERY_VERBOSE = 3
}

var db: SQLite = null
@export_group("File and Directory Names", "db_")
@export var db_filename: String = "sqlite"
@export var db_subdirectory_name: String = "database"
@export var db_migrations_subdirectory_name: String = "migrations"

@export_category("Settings")
@export var verbosity_level: Verbosity
@export var enable_foreign_keys: bool = true
@export var read_only: bool = false

func _enter_tree() -> void:
	assert(_open_connection(), "connection to the internal database failed")
	_check_and_run_migrations()

func is_dev() -> bool:
	return OS.has_feature("editor")

func env() -> String:
	return "development" if is_dev() else "production"

const DEV_DATA_DIR: String = "res://tmp/data"
const PROD_DATA_DIR: String = "user://"

func get_data_dir_path() -> String:
	return DEV_DATA_DIR if is_dev() else PROD_DATA_DIR

func _exit_tree() -> void:
	_close_connection()

func _get_db_dir() -> String:
	var dir = Application.get_data_dir_path().path_join(db_subdirectory_name)
	DirAccess.make_dir_recursive_absolute(dir)
	return dir

func _get_db_path() -> String:
	var base_path = _get_db_dir()
	return base_path.path_join(db_filename)

func _get_db_migrations_dir() -> String:
	var dir = "res://addons/database_access_layer".path_join(db_migrations_subdirectory_name)
	DirAccess.make_dir_recursive_absolute(dir)
	return dir

func _get_db_backup_path() -> String:
	var base_path = Database._get_db_tmp_dir().path_join("backup")
	DirAccess.make_dir_recursive_absolute(base_path)
	return base_path.path_join("%s_bkp")

func _get_db_tmp_dir() -> String:
	var path: String = _get_db_dir().path_join("tmp")
	DirAccess.make_dir_recursive_absolute(path)
	return path

func _open_connection() -> bool:
	db = SQLite.new()
	var path = _get_db_path()
	logger.info("opening database connection")
	db.path = path
	db.verbosity_level = verbosity_level
	db.foreign_keys = enable_foreign_keys
	db.read_only = read_only
	var result = db.open_db()
	if result: logger.info("database connection to %s successful" % path)
	else: logger.error("database to %s connection failed" % path)
	return result

func _close_connection() -> bool:
	logger.info("closing database connection")
	if db == null:
		logger.warn("attempted to close database connection, but none exist")
		return false
	return db.close_db()

func _ensure_connection() -> void:
	logger.info("verifying sqlite connection")
	db = SQLite.new()
	db.path = _get_db_path()
	db.verbosity_level = SQLite.VERBOSE
	_test_connection()

func _test_connection() -> bool:
	db.open_db()
	var result = db.query("SELECT name FROM sqlite_master WHERE type='table';")
	db.close_db()
	return result

func _check_and_run_migrations() -> bool:
	var runner = MigrationRunner.new(db, _get_db_migrations_dir())
	runner.run()
	# FIX: This is always returning true
	return true

func begin_transaction() -> bool:
	return db.query("BEGIN;")

func rollback_transaction() -> bool:
	return db.query("ROLLBACK;")

func commit_transaction() -> bool:
	return db.query("COMMIT:")

func _execute_transaction(transaction: DatabaseTransaction) -> bool:
	begin_transaction()
	for statement in transaction.statements:
		if !db.query(statement):
			rollback_transaction()
			return false
	commit_transaction()
	return true

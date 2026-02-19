## Facilitates connections to an embedded sqlite instance. ## Responsible for issuing and managing connections and threads
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

@export var db_name: String = "sqlite"
@export var db_subdirectory_name: String = "database"
@export var db_migrations_subdirectory_name: String = "migrations"

@export var default_context: DatabaseConnectionContext

@export var initial_read_connections: int = 4

func _ready() -> void:
	logger.info("creating %s initial database connections for connection pool" % initial_read_connections)
	_create_initial_connections()

######################################################################
# General Utilities
######################################################################

func is_dev() -> bool:
	return OS.has_feature("editor")

const DEV_DATA_DIR: String = "res://tmp/data"
const PROD_DATA_DIR: String = "user://"

func get_data_dir_path() -> String:
	return DEV_DATA_DIR if is_dev() else PROD_DATA_DIR

func get_db_dir() -> String:
	var dir = get_data_dir_path().path_join(db_subdirectory_name)
	DirAccess.make_dir_recursive_absolute(dir)
	return dir

func get_db_path() -> String:
	var base_path = get_db_dir()
	return base_path.path_join(db_name)

func get_db_migrations_dir() -> String:
	var dir = "res://addons/database_access_layer".path_join(db_migrations_subdirectory_name)
	DirAccess.make_dir_recursive_absolute(dir)
	return dir

func get_db_backup_path() -> String:
	var base_path = Database._get_db_tmp_dir().path_join("backup")
	DirAccess.make_dir_recursive_absolute(base_path)
	return base_path.path_join("%s_bkp")

func get_db_tmp_dir() -> String:
	var path: String = get_db_dir().path_join("tmp")
	DirAccess.make_dir_recursive_absolute(path)
	return path

#######################################################################
# Connection Management
######################################################################

var _connections: Dictionary[DatabaseConnection, bool] = {}

func _create_database_connection(context: DatabaseConnectionContext = default_context) -> DatabaseConnection:
	var c = DatabaseConnection.create(context)
	_connections.set(c, true)
	add_child(c, true)
	return c

func _create_initial_connections() -> void:
	for i in range(initial_read_connections):
		_create_database_connection()

#######################################################################
# Query Execution
######################################################################
var dispatcher: Dispatcher

func _initialize_dispatcher() -> void:
	dispatcher = Dispatcher.new()
	add_child(dispatcher, true)

var query_queue: Array[DatabaseQuery] = []

func add_query_request(query: DatabaseQuery) -> void:
	query_queue.push_back(query) 

func get_query() -> DatabaseQuery:
	return query_queue.pop_front()


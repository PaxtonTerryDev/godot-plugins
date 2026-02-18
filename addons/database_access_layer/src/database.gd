## Facilitates connections to an embedded sqlite instance. 
## Responsible for issuing and managing connections and threads
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

enum ConnectionType {
	READ,
	WRITE,
}

@export var db_name: String = "sqlite"
@export var db_subdirectory_name: String = "database"
@export var db_migrations_subdirectory_name: String = "migrations"

@export var default_context: DatabaseConnectionContext

@export var initial_read_connections: int = 4

func _ready() -> void:
	initialize_default_connections()
######################################################################
# General Utilities
######################################################################
func is_dev() -> bool:
	return OS.has_feature("editor")

func env() -> String:
	return "development" if is_dev() else "production"

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

func initialize_default_connections() -> bool:
	var write_connection = _create_connection(Database.ConnectionType.WRITE).open_database_connection()
	if !write_connection: 
		logger.error("failed to initialize write connection to database")
		return false
	for i in range(initial_read_connections):
		var read_connection
		if !read_connection: 
			logger.error("failed to initialize read connection to database")
			return false
	return true

signal connection_taken(requestor: Node, connection_id: String)
signal connection_released(connection_id: String)

# This will have a thread that basically pops the query, executes it and then returns
# If thie nodes are living in scene tree, I need to figure out a way to prevent them from being accessed while the runner is accessing it. Actually, maybe the mutex lives inside of the query itself, since we just need to handle the response internally
var requestor_queue: Array[DatabaseQuery] = []

var available_connections: Dictionary[Database.ConnectionType, Dictionary] = {
	Database.ConnectionType.READ: {},
	Database.ConnectionType.WRITE: {},
	}

var in_use_connections: Dictionary[Database.ConnectionType, Dictionary] = {
	Database.ConnectionType.READ: {},
	Database.ConnectionType.WRITE: {},
	}

func is_connection_available(type: Database.ConnectionType) -> bool:
	return available_connections[type].keys().size() > 0

func request_connection(requestor: DatabaseQuery) -> void:
	requestor_queue.push_back(requestor)

func _create_connection(type: Database.ConnectionType = Database.ConnectionType.READ, context: DatabaseConnectionContext = default_context) -> DatabaseConnection:
	var c = DatabaseConnection.create(context, type)
	add_child(c, true)
	available_connections[type][c.id] = c
	return c

#
# func _check_and_run_migrations() -> bool:
# 	var runner = MigrationRunnerDEP.new(db, _get_db_migrations_dir())
# 	add_child(runner)
# 	var result = runner.run()
# 	runner.queue_free()
# 	return result
#


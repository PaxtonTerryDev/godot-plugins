class_name QueryRunner extends RefCounted

var logger = Syslog.new(['Database', "QueryRunner"])
var _query: DatabaseQuery
var _connection: DatabaseConnection

func _init(query: DatabaseQuery, connection: DatabaseConnection, mutex: Mutex) -> void:
	_query = query
	_connection = connection

func run() -> void:
	logger.info("starting query execution")

func _exec_query_run() -> void:
	var result = _query.exec(_connection.db)
	_query.result = result

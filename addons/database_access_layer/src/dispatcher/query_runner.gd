class_name QueryRunner extends RefCounted

var logger = Syslog.new(['Database', "QueryRunner"])
var _query: DatabaseQuery
var _mutex: Mutex
var _connection: DatabaseConnection

func _init(query: DatabaseQuery, connection: DatabaseConnection, mutex: Mutex) -> void:
	_query = query
	_mutex = mutex
	_connection = connection

func run() -> void:
	logger.info("starting query execution")
	if _query.type == Database.ConnectionType.WRITE:
		_mutex.lock()
		_exec_query_run()
		_mutex.unlock()
	_exec_query_run()

func _exec_query_run() -> void:
	var result = _query.exec(_connection.connection)
	_query.result = result


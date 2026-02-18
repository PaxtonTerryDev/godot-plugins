class_name Dispatcher extends Node

@export var thread_count: int = 2

var _threads: Array[Thread] = []
var _write_mutex: Mutex = Mutex.new()

func _initialize_threads() -> void:
	for i in range(thread_count):
		_threads.push_back(Thread.new())

func _can_dispatch() -> bool:
	return _threads.size() > 0

func dispatch(query: DatabaseQuery, connection: DatabaseConnection, mutex: Mutex) -> void:
	var thread = _threads.pop_back()
	var runner = QueryRunner.new(query, connection, mutex)
	thread.start(runner.run())
	

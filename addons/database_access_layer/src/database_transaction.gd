class_name DatabaseTransaction extends RefCounted

var statements: Array[String]

func _init(initial_statements: Array[String] = []) -> void:
	statements = initial_statements

func add(statement: String) -> void:
	statements.push_back(statement)




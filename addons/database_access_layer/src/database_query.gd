@abstract class_name DatabaseQuery extends Resource

@export var type: Database.ConnectionType = Database.ConnectionType.READ
@export var table_name: String

signal query_completed(data: Array)
var result: Array:
	get: return result
	set(value):
		result = value
		query_completed.emit(result)

@abstract func exec(db: SQLite) -> Array




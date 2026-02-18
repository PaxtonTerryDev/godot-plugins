class_name DatabaseSelectOneQuery extends DatabaseQuery

@export var conditions: String = ""
@export var columns: Array[String] = []

func exec(db: SQLite) -> Array:
	return db.select_rows(table_name, conditions, columns)


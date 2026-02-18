class_name DatabaseDeleteRowsQuery extends DatabaseQuery

@export var conditions: String = ""

func exec(db: SQLite) -> Array:
	db.delete_rows(table_name, conditions)
	return []

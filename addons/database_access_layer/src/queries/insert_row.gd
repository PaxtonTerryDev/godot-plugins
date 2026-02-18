class_name DatabaseInsertRowQuery extends DatabaseQuery

@export var row: Dictionary = {}

func exec(db: SQLite) -> Array:
	db.insert_row(table_name, row)
	return []

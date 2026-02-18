class_name DatabaseInsertRowsQuery extends DatabaseQuery

@export var rows: Array = []

func exec(db: SQLite) -> Array:
	db.insert_rows(table_name, rows)
	return []

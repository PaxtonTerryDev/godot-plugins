class_name DatabaseUpdateRowsQuery extends DatabaseQuery

@export var conditions: String = ""
@export var updated_row: Dictionary = {}

func exec(db: SQLite) -> Array:
	db.update_rows(table_name, conditions, updated_row)
	return []

class_name DatabaseRawQuery extends DatabaseQuery

@export var sql: String = ""

func exec(db: SQLite) -> Array:
	db.query(sql)
	return db.query_result

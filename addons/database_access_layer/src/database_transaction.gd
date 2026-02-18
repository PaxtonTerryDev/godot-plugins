class_name DatabaseTransaction extends DatabaseQuery

@export var queries: Array[DatabaseQuery]

func exec(db: SQLite) -> Array:
	begin_transaction(db)
	var data: Array = []
	for query in queries:
		var query_result = query.exec(db)
		data.push_back(query_result)
		if db.error_message != "":
			rollback_transaction(db)
			Database.logger.error("database query failed - rolling back transaction.  Error: %s" % db.error_message)
			return []
	commit_transaction(db)
	return data

func add(query: DatabaseQuery) -> void:
	if query is DatabaseTransaction:
		for q in query.queries:
			add(q)
	else:
		queries.push_back(query)

func begin_transaction(db: SQLite) -> bool:
	return db.query("BEGIN;")

func rollback_transaction(db: SQLite) -> bool:
	return db.query("ROLLBACK;")

func commit_transaction(db: SQLite) -> bool:
	return db.query("COMMIT;")



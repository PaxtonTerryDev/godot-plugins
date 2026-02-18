## Collects sql statements and executes them wrapped in a SQLite transaction. Most commonly used for inserts, and most commonly batched inserts
##
## It is assumed that this data is immutable, and the data being referenced will not be accessed after being inserted into the database
class_name DatabaseTransaction extends Node

var db: SQLite

func _init(_db: SQLite) -> void:
	db = _db



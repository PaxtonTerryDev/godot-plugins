class_name DatabaseConnection extends Node
var id: String = UUID.generate_compact()
var context: DatabaseConnectionContext
var db: SQLite

func open_database_connection(verbosity: Database.Verbosity = Database.Verbosity.NORMAL) -> bool:
	db = SQLite.new()
	db.path = Database.get_db_path()
	db.verbosity_level = verbosity
	db.foreign_keys = context.foreign_keys
	db.read_only = context.read_only

	return db.open_db()

func close_database_connection() -> bool:
	return db.close_db()

static func create(_context: DatabaseConnectionContext = Database.default_context) -> DatabaseConnection:
	var c = DatabaseConnection.new()
	c.context = _context
	c.name = "DatabaseConnection_%s" % c.id
	return c

func _enter_tree() -> void:
	open_database_connection()

func _exit_tree() -> void:
	close_database_connection()

class_name DatabaseConnection extends Node
var id: String = UUID.generate()
var type: Database.ConnectionType
var context: DatabaseConnectionContext
var connection: SQLite

func open_database_connection() -> bool:
	connection = SQLite.new()
	connection.path = Database.get_db_path()
	connection.verbosity = context.verbosity_level
	connection.foreign_keys = context.foreign_keys
	connection.read_only = true if type == Database.ConnectionType.READ else false
	return connection.open_db()

static func create(_context: DatabaseConnectionContext = Database.default_context, _type: Database.ConnectionType = Database.ConnectionType.READ) -> DatabaseConnection:
	var conn = DatabaseConnection.new()
	conn.type = _type
	conn.context = _context
	conn.name = "DatabaseConnection_%s" % conn.id
	return conn

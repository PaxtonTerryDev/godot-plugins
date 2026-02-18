class_name MigrationRunnerDEP extends Node

# TODO: Godot Sqlite ships with a backup_to and restore_from method.  We should use these to ensure we don't end up corrupting player data on accident during a migration after a patch 
# TODO: Need to implement either rollbacks or transactions when applying the migrations
var logger = Syslog.new(["Database", "MigrationRunnerDEP"])
var _db: SQLite
var _migrations_dir: String

func _init(db: SQLite, migrations_dir: String) -> void:
	_db = db
	_migrations_dir = migrations_dir

func run() -> bool:
	var user_version: int = _get_current_user_version()
	var migrations: Array = _get_migration_lock()
	var is_needed = _check_migrations_needed(user_version, migrations.size())
	if !is_needed:
		logger.info("database is current. no migrations applied")
		return true
	else:
		logger.info("database is not current. applying new migrations")
		var backup = _create_database_backup()
		if !backup:
			logger.error("unable to create backup. aborting migration")
			return false
		logger.info("successfully created backup at %s" % Database._get_db_backup_path())
		var version = user_version + 1
		Database.begin_transaction()
		for migration in migrations.slice(user_version):
			var sql = _get_migration_sql(migration)
			var result = _apply_migration(migration, sql, version)
			if !result:
				logger.error("migration failed - rolling back changes")
				logger.error(_db.error_message)
				Database.rollback_transaction()
			version += 1
		Database.commit_transaction()
		return true

func _create_database_backup() -> bool:
	return _db.backup_to(Database._get_db_backup_path())

func _check_migrations_needed(user_version: int, migrations_count: int) -> bool:
	logger.info("current user version: %s :: migration count: %s" % [user_version, migrations_count])
	return migrations_count > user_version

const MIGRATION_PROP_NAME: String = "migrations"

func _get_migration_lock() -> Array:
	var path = _migrations_dir.path_join("migration_lock.json")
	assert(FileAccess.file_exists(path), "no migration lock file found. %s is an invalid path" % path)
	var file_str: String = FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(file_str)
	var migrations = parsed[MIGRATION_PROP_NAME]
	return migrations

func _get_migration_filepath(migration: String):
	return _migrations_dir.path_join("%s.sql" % migration)

func _get_migration_sql(migration_id: String) -> String:
	logger.info("getting sql for migration file %s" % migration_id)
	var path = _get_migration_filepath(migration_id)
	assert(FileAccess.file_exists(path),"no migration file found for %s" % migration_id)
	var sql_str = FileAccess.get_file_as_string(path)
	assert(sql_str.length() > 0, "no sql present in file %s. Error: %s" % [migration_id, FileAccess.get_open_error()])
	return sql_str

func _apply_migration(migration: String, sql: String, new_version: int) -> bool:
	var temp_log = logger.temp_scope(migration)
	temp_log.info("starting migration %s" % migration)
	var result = _db.query(sql)
	if result:
		_set_user_version(new_version)
		temp_log.info("migration %s successful. new user_version is %s" % [migration, new_version])
	else:
		temp_log.error("migration %s failed" % migration)
	return result

func _get_current_user_version() -> int:
	_db.query("PRAGMA user_version")
	return _db.query_result[0]["user_version"]

func _set_user_version(version: int) -> void:
	_db.query("PRAGMA user_version = %s" % version)

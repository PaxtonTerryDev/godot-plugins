class_name Syslog extends RefCounted

const GLOBAL_VERBOSITY: Verbosity = Verbosity.NORMAL

const _MAX_LEVEL_LEN: int = 8  # length of "[ERROR] "
static var _max_scope_display_len: int = 0

const ENABLED_LEVELS_VERBOSITY: Dictionary[String, Verbosity] = {
	"DEBUG": Verbosity.VERBOSE,
	"INFO": Verbosity.NORMAL,
	"WARN": Verbosity.NORMAL,
	"ERROR": Verbosity.QUIET
	}

func is_log_enabled(level: String) -> bool:
	return _verbosity >= ENABLED_LEVELS_VERBOSITY[level]

enum Verbosity {
	QUIET,
	NORMAL,
	VERBOSE
}
var _verbosity: Verbosity = Verbosity.NORMAL
var scopes: Dictionary[String, bool] = {}
var _normalize: bool = false

func format_scope() -> String:
	var active_scopes: Array[String] = []
	for scope in scopes.keys():
		if scopes[scope]: active_scopes.push_back(scope)
	return "|".join(active_scopes)

## Add a new scope to the logger.  This is appended to the current scopes
func add_scope(new_scope: String) -> void:
	scopes.set(new_scope, true)
	_update_max_scope_len()

## Permanently remove the target scope from the logger.
func remove_scope(target_scope: String) -> void:
	scopes.erase(target_scope)

func disable_scope(target_scope: String) -> void:
	scopes[target_scope] = false

func enable_scope(target_scope: String) -> void:
	scopes[target_scope] = true

func temp_scope(_temp_scope: String) -> Syslog:
	var t = Syslog.new()
	t.scopes = scopes.duplicate()
	t._normalize = _normalize
	t.scopes.set(_temp_scope, true)  # bypass add_scope — temp scopes don't affect global max
	return t

func _update_max_scope_len() -> void:
	var all_keys: Array = scopes.keys()
	if all_keys.is_empty(): return
	var candidate: int = ("(%s)  " % "|".join(all_keys)).length()
	if candidate > _max_scope_display_len:
		_max_scope_display_len = candidate

## Returns a formatted log string
func format_log(_level: String = "", _message: String = "") -> String:
	var _scope = format_scope()
	var formatted_message = ""
	if _normalize:
		var level_part = "[%s] " % _level if _level.length() > 0 else ""
		formatted_message += level_part.rpad(_MAX_LEVEL_LEN)
		var scope_part = "(%s)  " % _scope if _scope.length() > 0 else ""
		formatted_message += scope_part.rpad(_max_scope_display_len)
	else:
		if _level.length() > 0: formatted_message += "[%s] " % _level
		if _scope.length() > 0: formatted_message += "(%s)  " % _scope
	formatted_message += _message
	return formatted_message

## Print a blank space to the console
static func print_spacer() -> void:
	print()

## Print a debug log -> this does not include a level, but does include a scopes.  If you do not want a scopes, you can just call `print` directly
func debug(message: String, spacer: bool = false) -> void:
	if !is_log_enabled("DEBUG"): return
	print(format_log("", message))
	if spacer: Syslog.print_spacer()

## Prints an info log
func info(message: String, spacer: bool = false) -> void:
	if !is_log_enabled("INFO"): return
	print(format_log("INFO", message))
	if spacer: Syslog.print_spacer()

## Prints a warning log
func warn(message: String, push_warning: bool = true, spacer: bool = false) -> void:
	if !is_log_enabled("WARN"): return
	print(format_log("WARN", message))
	if push_warning: push_warning(format_log("", message))
	if spacer: Syslog.print_spacer()

## Prints an error log
func error(message: String, push_error: bool = true, spacer: bool = false) -> void:
	if !is_log_enabled("ERROR"): return
	print(format_log("ERROR", message))
	if push_error: push_error(format_log("", message))
	if spacer: Syslog.print_spacer()

func _init(initial_scopes: PackedStringArray = [], normalize: bool = false, verbosity: Verbosity = GLOBAL_VERBOSITY,) -> void:
	for s in initial_scopes:
		scopes.set(s, true)
	if not scopes.is_empty():
		_update_max_scope_len()
	_normalize = normalize
	_verbosity = verbosity

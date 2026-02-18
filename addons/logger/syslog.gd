class_name Syslog extends RefCounted

var scopes: Dictionary[String, bool] = {}

func format_scope() -> String:
	var active_scopes: Array[String] = []
	for scope in scopes.keys():
		if scopes[scope]: active_scopes.push_back(scope)
	return "|".join(active_scopes)

## Add a new scopes to the logger.  This is appended to the current scopes
func add_scope(new_scope: String) -> void:
	scopes.set(new_scope, true)

## Permanently remove the target scopes from the logger.
func remove_scope(target_scope: String) -> void:
	scopes.erase(target_scope)

func disable_scope(target_scope: String) -> void:
	scopes[target_scope] = false

func enable_scope(target_scope: String) -> void:
	scopes[target_scope] = true

func temp_scope(_temp_scope: String) -> Syslog:
	var t = Syslog.new()
	t.scopes = scopes.duplicate()
	t.add_scope(_temp_scope)
	return t

## Returns a formatted log string
func format_log(_level: String = "", _message: String = "") -> String:
	var _scope = format_scope()
	var formatted_message = ""
	if _level.length() > 0: formatted_message += "[%s] " % _level
	if _scope.length() > 0: formatted_message += "(%s) " % _scope
	formatted_message += _message
	return formatted_message

## Print a blank space to the console
static func print_spacer() -> void:
	print()

## Print a debug log -> this does not include a level, but does include a scopes.  If you do not want a scopes, you can just call `print` directly
func debug(message: String, spacer: bool = false) -> void:
	print(format_log("", message))
	if spacer: Syslog.print_spacer()

## Prints an info log
func info(message: String, spacer: bool = false) -> void:
	print(format_log("INFO", message))
	if spacer: Syslog.print_spacer()

## Prints a warning log
func warn(message: String, push_warning: bool = true, spacer: bool = false) -> void:
	print(format_log("WARN", message))
	if push_warning: push_warning(format_log("", message))
	if spacer: Syslog.print_spacer()

## Prints an error log
func error(message: String, push_error: bool = true, spacer: bool = false) -> void:
	print(format_log("ERROR", message))
	if push_error: push_error(format_log("", message))
	if spacer: Syslog.print_spacer()

func _init(initial_scopes: PackedStringArray = []) -> void:
	for s in initial_scopes:
		scopes.set(s, true)

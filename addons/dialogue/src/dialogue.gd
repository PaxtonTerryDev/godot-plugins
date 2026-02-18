extends Node

var logger = Syslog.new(["Dialogue"])

signal event_triggered(event_name: String)

func _ready() -> void:
	logger.info("system active")

func trigger_event(event_name: String) -> void:
	logger.info("triggering event: %s" % event_name)

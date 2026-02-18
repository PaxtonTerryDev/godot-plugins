extends Node2D

func _ready() -> void:
	var main_logger = Syslog.new(["Main"])
	main_logger.info("this is a standard info message")
	var no_scope_logger = Syslog.new()
	no_scope_logger.info("this is a message without a scope")
	no_scope_logger.debug("the debug method doesn't include a level")
	main_logger.debug("but you can also include a scope if you want")

	main_logger.info("you can also print a follower space by adding a true argument after your message", true)
	main_logger.info("^ See!")
	main_logger.info("you can also print out a spacer by just calling the static `Syslog.print_spacer()` method")
	Syslog.print_spacer()

	main_logger.warn("warn piggybacks off godot's warn log, but includes the scope and message you provide.  It also prints to stdout, which you should be able to see in the output panel")
	main_logger.warn("but if you don't want the warning in the debugger, you can just pass false as the next argument. (Note, this makes the signature different than debug and info)", false, true)

	main_logger.error("you can also push errors as well, using the same signature as warn. This will get pushed to the debugger panel")
	main_logger.error("and this won't", false, true)

	main_logger.add_scope("AdditionalScope")
	main_logger.info("You can append scopes by calling the `add_scope` method", true)

	main_logger.remove_scope("AdditionalScope")
	main_logger.info("And remove them with `remove_scope` while passing the scope string.  This must match exactly", true)

	main_logger.temp_scope("TemporaryScope").info("you can create a temporary scope by prepending the log function with `temp_scope`.  Note - this creates a copy of the log, so if you keep a reference to it, it will be dangling")
	main_logger.info("See! It's gone now")

	main_logger.disable_scope("Main")
	main_logger.info("finally, you can disable / enable scopes by calling `disable_scope(scope) or `enable_scope(scope)`", true)

	main_logger.enable_scope("Main")
	main_logger.info("See! It's back now")



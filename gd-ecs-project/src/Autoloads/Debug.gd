extends Node

var _rate_limits := {}


func print(val, rate_limit := 0.0, error := false):
	# rate_limit is how often to print in seconds.
	var stack = get_stack()
	if not stack:
		print(val)
		return
	var source_file = stack[1].source
	var source_function = stack[1].function
	var source_line = stack[1].line
	var source_name = source_file.rsplit("/", true, 1)[-1]
	var identifier = "%s|%s|%s" % [source_file, source_function, source_line]

	var formatted = "[%s:%s] %s" % [source_name, source_line, val]
	if error:
		formatted = "[%s:%s] [ERROR] %s" % [source_name, source_line, val]
		push_error(formatted)
	# Uncomment below if you want it to be formatted exactly like GDScript's built-in print_debug() statement
	# formatted = "%s\n   At: %s:%s:%s()" % [val,  source_file, source_line, source_function]

	var last_printed = _rate_limits.get(identifier, -INF)

	if OS.get_ticks_msec() - last_printed > rate_limit * 1000:
		print(formatted)
		if rate_limit > 0:
			_rate_limits[identifier] = OS.get_ticks_msec()


func print_err(val, rate_limit := 0.0):
	self.print(val, rate_limit, true)

class_name S_ActionEventEmitter
extends System

const MS_PER_TICK: float = 1000.0 / Globals.INPUT_TPS

# max ms in between a double tap to consider it a doubletap
export var double_tap_delay := 250

var _double_tap_history_size: int


func _init() -> void:
	system_name = "S_ActionEventEmitter"
	requirements = ["C_Input"]
	tps = Globals.INPUT_TPS


func _ready() -> void:
	# double_tap_delay is an exported variable so need to wait until _ready()
	_double_tap_history_size = ceil(double_tap_delay / MS_PER_TICK)


func _system_process(entities: Array, delta: float) -> void:
	for e in entities:
		var inputs: Array = e.get_components("C_Input")
		for input in inputs:
			if input.history.size() <= _double_tap_history_size:
				continue
			var previous_state: Dictionary = input.history.back()
			var current_state: Dictionary = input.state

			for action in current_state:
				if is_action_double_pressed(action, current_state, input.history):
					system_manager.emit("action_double_pressed", e, action)
					# if the action is double-pressed, don't want to emit a normal pressed signal so continue
					continue
				if previous_state.get(action) != current_state.get(action):
					if current_state.get(action):
						system_manager.emit("action_pressed", e, action)
					else:
						system_manager.emit("action_released", e, action)


func is_action_double_pressed(action: int, current_state: Dictionary, history: Array) -> bool:
	var size := history.size() - 1
	var slice := history.slice(size - _double_tap_history_size + 1, size)

	var pressed_flag: bool = false
	var released_flag: bool = false
	var _prev_tick: Dictionary = slice.pop_front()
	for _this_tick in slice:
		# check that the input was pressed for the first time
		if _prev_tick.get(action) == false and _this_tick.get(action) == true:
			pressed_flag = true
		# after the input was pressed, the input was released
		if pressed_flag and _prev_tick.get(action) == true and _this_tick.get(action) == false:
			released_flag = true
		# if a DIFFERENT action is pressed, reset the flags
		if is_other_action_pressed(action, _this_tick, _prev_tick):
			pressed_flag = false
			released_flag = false
		# if after the release, the input is pressed again, return false.
		# Don't want to count double presses more than once every double_tap_delay ms.
		if released_flag and _this_tick.get(action) == true:
			return false
		_prev_tick = _this_tick

	# if it was pressed and released exactly once, and the current state is pressed, it is double-pressed this tick
	return released_flag and current_state.get(action) == true


# Given an input state, return whether any of the values NOT action are true
func is_other_action_pressed(action: int, current_state: Dictionary, previous_state: Dictionary) -> bool:
	for a in current_state:
		if a == action:
			continue
		if current_state[a] == true and previous_state[a] == false:
			return true
	return false

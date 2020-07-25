class_name C_Input
extends Node

const component_name := "C_Input"

export var max_history: int = 100

var history: Array = []
var state: Dictionary = {
	Globals.InputAction.MOVE_UP: false,
	Globals.InputAction.MOVE_DOWN: false,
	Globals.InputAction.MOVE_LEFT: false,
	Globals.InputAction.MOVE_RIGHT: false,
	Globals.InputAction.JUMP: false,
}


func is_action_pressed(action: int) -> bool:
	return state.get(action)


func is_action_released(action: int) -> bool:
	return not is_action_pressed(action)


func set_action_pressed(action: int) -> void:
	state[action] = true


func set_action_released(action: int) -> void:
	state[action] = false


static func get_action_string(action: int) -> String:
	return Globals.InputAction.keys()[action]

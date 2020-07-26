class_name System
extends Node

var entity_filter: Array
var system_manager: SystemManager
var system_name: String
var requirements: Array
var tps: float


func _system_init(_system_manager: SystemManager) -> bool:
	system_manager = _system_manager
	return true


func _system_ready() -> void:
	pass


func _system_process(_entities: Array, _delta: float) -> void:
	pass


func _system_physics_process(_entities: Array, _delta: float) -> void:
	pass

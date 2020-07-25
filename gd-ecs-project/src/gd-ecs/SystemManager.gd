tool
class_name SystemManager
extends Node
# A SystemManager manages child systems

var query_manager := QueryManager.new(self)
var systems: Array = []
var _tps_map: Dictionary


func _ready() -> void:
	if Engine.editor_hint:
		return

	query_manager.name = "QueryManager"
	add_child(query_manager)

	systems = get_systems()

	for system in systems:
		system.requirements.sort()
		query_manager.register_requirements(system.requirements)

		var tps: float = system.get("tps") if system.get("tps") else 0.0
		var seconds_per_tick := 1.0 / tps if tps else 0.0
		_tps_map[system] = Vector2(seconds_per_tick, seconds_per_tick)

	query_manager.ready()

	for system in systems:
		if system.has_method("_system_ready"):
			system.call("_system_ready")


func _process(delta: float) -> void:
	if Engine.editor_hint:
		return
	for system in systems:
		if not system.has_method("_system_process"):
			continue
		var tps_vec: Vector2 = _tps_map[system]
		if tps_vec.x > 0:
			tps_vec.y += delta
			if tps_vec.y < tps_vec.x:
				_tps_map[system] = tps_vec
				continue
			system.call("_system_process", query_entities(system), tps_vec.y)
			tps_vec.y -= tps_vec.x
			_tps_map[system] = tps_vec
		else:
			system.call("_system_process", query_entities(system), delta)


func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	for system in systems:
		if not system.has_method("_system_physics_process"):
			continue
		system.call("_system_physics_process", query_entities(system), delta)


func _get_configuration_warning() -> String:
	var _systems := get_systems()
	if _systems.size() == 0:
		return "This node has no Systems, so it will have nothing to operate on. Add child Systems for functionality."
	return ""


# Emits a payload to a destination. Any subscribed components will receive the payload
func emit(destination: String, payload) -> void:
	if not payload is Array:
		payload = [payload]
	payload.insert(0, get_destination_signal(destination))
	callv("emit_signal", payload)


func get_systems() -> Array:
	var results := []
	for child in get_children():
		if ECS.is_system(child):
			if Engine.editor_hint:
				results.append(child)
			elif validate_system(child):
				results.append(child)
	return results


func get_destination_signal(destination: String) -> String:
	var dest_signal: String = "EventBus|%s" % destination
	if not has_user_signal(dest_signal):
		add_user_signal(dest_signal)
	return dest_signal


func query_entities(system: Node) -> Array:
	var entity_filter: Array = system.get("entity_filter") if "entity_filter" in system else []
	return query_manager.query(system.requirements, entity_filter)


# Subscribes to a destination. callback_name is the method to be called.
func subscribe(destination: String, system: Node, callback_name: String) -> void:
	var dest_signal: String = get_destination_signal(destination)
	if not is_connected(dest_signal, system, callback_name):
		# warning-ignore: return_value_discarded
		connect(dest_signal, system, callback_name)


func validate_system(system: Node) -> bool:
	if not system.has_method("_system_init"):
		push_error(
			"[System:%s] does not have a _system_init() method. Skipping." % system.system_name
		)
		return false
	if not system.call("_system_init", self):
		push_error(
			"[System:%s]  _system_init() method returned false. Skipping." % system.system_name
		)
		return false
	if not system.requirements:
		push_error(
			"[System:%s] attempted to register with no requirements. Skipping." % system.system_name
		)
		return false
	return true

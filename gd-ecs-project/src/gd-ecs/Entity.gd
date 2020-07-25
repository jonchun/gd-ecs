class_name Entity
extends Node

var components := []
var id setget _ro_setter, _id_getter


func _init() -> void:
	add_to_group("Entity")


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	for child in get_children():
		register_component(child)


func add_child(node: Node, legible_unique_name := true) -> void:
	if ECS.is_component(node) and legible_unique_name:
		node.name = node.component_name
	.add_child(node, legible_unique_name)


# Returns the first matching component
func get_component(component_name: String) -> Node:
	for component in components:
		if component.component_name == component_name:
			return component
	return null


# Returns all matching components
func get_components(component_name: String) -> Array:
	var results: Array
	for component in components:
		if component.component_name == component_name:
			results.append(component)
	return results


func get_component_names() -> Array:
	var results := []
	for component in components:
		results.append(component.component_name)
	return results


# Checks to see if this entity meets the requirements provided.
# requirements is an Array of Strings containing Component names. Prefix with ! for negation.
func meets_requirements(requirements: Array) -> bool:
	var matching_requirements := 0
	for component in components:
		if "!%s" % component.component_name in requirements:
			return false
		if component.component_name in requirements:
			matching_requirements += 1

	# possible to have multiple matching requirements if you have multiples of the same component
	if matching_requirements >= requirements.size():
		return true
	return false


func register_component(node: Node) -> void:
	if ECS.is_component(node):
		components.append(node)


func unregister_component(node: Node) -> void:
	# warning-ignore: return_value_discarded
	components.erase(node)


func _id_getter() -> int:
	return get_instance_id()


func _ro_setter(_val: String) -> void:
	pass

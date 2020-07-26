class_name ECS

static func is_component(node: Node) -> bool:
	return true if node.get("component_name") else false

static func is_entity(node: Node) -> bool:
	return node.is_in_group("Entity")

static func is_system(node: Node) -> bool:
	return true if node.get("system_name") else false

static func matches_entity_filter(entity: Node, filter: Array) -> bool:
	var entity_class: String = entity.get_class()
	if not entity_class in filter or "!%s" % entity_class in filter:
		return false
	return true

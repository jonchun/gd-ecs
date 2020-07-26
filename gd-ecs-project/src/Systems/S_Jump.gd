class_name S_Jump
extends System


func _init() -> void:
	entity_filter = ["KinematicBody2D"]
	system_name = "S_Jump"
	requirements = ["C_Jump", "C_Locomotion"]


func _system_ready() -> void:
	system_manager.subscribe("action_pressed", self, "_on_action_pressed")
	system_manager.subscribe("action_released", self, "_on_action_released")


func _system_physics_process(entities: Array, _delta: float) -> void:
	for e in entities:
		var jump: C_Jump = e.get_component("C_Jump")
		if e.is_on_floor():
			jump.jump_count = 0


# TODO: Actually do coyote jump logic
func can_coyote_jump(entity: Entity) -> bool:
	return entity.is_on_floor()


func jump(entity: Entity) -> void:
	var jump: C_Jump = entity.get_component("C_Jump")
	var motion: C_Locomotion = entity.get_component("C_Locomotion")

	if jump.jump_count == 0 and can_coyote_jump(entity):
		jump.jump_count += 1
		# When calculating jump velocity, want to set initial y velocity to 0. Otherwise jumps will be too small if you try to jump mid-air.
		motion.velocity.y = 0.0
		var jump_velocity: Vector2 = Utils.calculate_velocity(
			motion.velocity, motion.max_speed, Vector2(0.0, jump.max_jump_impulse), 1.0, Vector2.UP
		)
		motion.velocity = jump_velocity
		system_manager.emit("play_animation", [entity, jump.jump_animation, 5])


func release_jump(entity: Entity) -> void:
	var jump: C_Jump = entity.get_component("C_Jump")
	var motion: C_Locomotion = entity.get_component("C_Locomotion")
	if abs(motion.velocity.y) > jump.min_jump_impulse:
		var jump_velocity: Vector2 = Utils.calculate_velocity(
			motion.velocity, motion.max_speed, Vector2(0.0, -jump.min_jump_impulse), 1.0, Vector2.UP
		)
		motion.velocity = jump_velocity


func _on_action_pressed(entity: Entity, action: int) -> void:
	if action != Globals.InputAction.JUMP:
		return
	if not entity.meets_requirements(requirements):
		return
	if not ECS.matches_entity_filter(entity, entity_filter):
		return
	jump(entity)


func _on_action_released(entity: Entity, action: int) -> void:
	if action != Globals.InputAction.JUMP:
		return
	if not entity.meets_requirements(requirements):
		return
	if not ECS.matches_entity_filter(entity, entity_filter):
		return
	release_jump(entity)

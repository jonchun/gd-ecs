class_name S_Jump
extends System


func _init() -> void:
	system_name = "S_Jump"
	requirements = ["C_IsKinematicBody2D", "C_Jump", "C_KinematicMotion2D"]


func _system_ready() -> void:
	system_manager.subscribe("action_pressed", self, "_on_action_pressed")


func _system_physics_process(entities: Array, delta: float) -> void:
	for e in entities:
		# This should never happened, but just in case...
		if not e is KinematicBody2D:
			return

		var jump: C_Jump = e.get_component("C_Jump")
		var motion: C_KinematicMotion2D = e.get_component("C_KinematicMotion2D")
		if e.is_on_floor():
			jump.jump_count = 0


func _on_action_pressed(entity: Entity, action: int) -> void:
	if action != Globals.InputAction.JUMP:
		return

	if not entity.meets_requirements(requirements):
		return
	jump(entity)


# This is duplicated code that can be found in S_KinematicMotion2D. Not sure if I prefer it coupled or duplicated.
static func calculate_velocity(
	old_velocity: Vector2,
	max_speed: Vector2,
	acceleration: Vector2,
	delta: float,
	move_direction: Vector2
) -> Vector2:
	var new_velocity := old_velocity

	new_velocity += move_direction * acceleration * delta
	new_velocity.x = clamp(new_velocity.x, -max_speed.x, max_speed.x)
	new_velocity.y = clamp(new_velocity.y, -max_speed.y, max_speed.y)

	return new_velocity

# TODO: Actually do coyote jump logic
static func can_coyote_jump(entity: Entity) -> bool:
	return entity.is_on_floor()

static func jump(e: Node) -> void:
	if not e is KinematicBody2D:
		return

	var jump: C_Jump = e.get_component("C_Jump")
	var motion: C_KinematicMotion2D = e.get_component("C_KinematicMotion2D")

	if jump.jump_count == 0:
		if can_coyote_jump(e):
			jump.jump_count += 1
			# When calculating jump velocity, want to set initial y velocity to 0. Otherwise jumps will be too small if you try to jump mid-air.
			motion.velocity.y = 0.0
			var jump_velocity: Vector2 = calculate_velocity(
				motion.velocity, motion.max_speed, Vector2(0.0, jump.jump_impulse), 1.0, Vector2.UP
			)
			motion.velocity = jump_velocity

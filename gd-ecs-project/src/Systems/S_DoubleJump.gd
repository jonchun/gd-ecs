class_name S_DoubleJump
extends System


func _init() -> void:
	entity_filter = ["KinematicBody2D"]
	system_name = "S_DoubleJump"
	requirements = ["C_DoubleJump", "C_Jump", "C_Locomotion"]


func _system_ready() -> void:
	system_manager.subscribe("action_double_pressed", self, "_on_action_pressed")
	system_manager.subscribe("action_pressed", self, "_on_action_pressed")


func _on_action_pressed(entity: Entity, action: int) -> void:
	if action != Globals.InputAction.JUMP:
		return
	if not entity.meets_requirements(requirements):
		return
	double_jump(entity)


func can_double_jump(entity: Entity, jump: C_Jump) -> bool:
	return not entity.is_on_floor() and jump.jump_count == 1


func double_jump(e: Node) -> void:
	if not e is KinematicBody2D:
		return

	var d_jump: C_DoubleJump = e.get_component("C_DoubleJump")
	var jump: C_Jump = e.get_component("C_Jump")
	var motion: C_Locomotion = e.get_component("C_Locomotion")

	if can_double_jump(e, jump):
		jump.jump_count += 1
		# When calculating jump velocity, want to set initial y velocity to 0. Otherwise jumps will be too small if you try to jump mid-air.
		motion.velocity.y = 0.0
		var jump_velocity: Vector2 = Utils.calculate_velocity(
			motion.velocity, motion.max_speed, Vector2(0.0, d_jump.jump_impulse), 1.0, Vector2.UP
		)
		motion.velocity = jump_velocity
		motion.min_y = e.global_position.y
		system_manager.emit("play_animation", [e, jump.jump_animation, 5])

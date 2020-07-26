class_name S_Locomotion
extends Node

const entity_filter := ["KinematicBody2D"]
const system_name := "S_Locomotion"
const requirements = ["C_Locomotion"]

export var top_down := false
export var gravity := Vector2(0, 1000)
export var friction_air := 1.0
export var friction_ground := 20.0

# move_and_slide parameters
export var up_direction := Vector2.UP
export var stop_on_slope := true
export var max_slides := 4
export var floor_max_angle := PI / 4
export var infinite_inertia := true


func _system_init(_system_manager: SystemManager) -> bool:
	return true


func _system_physics_process(entities: Array, delta: float) -> void:
	for e in entities:
		var input: C_Input = e.get_component("C_Input")
		var motion: C_Locomotion = e.get_component("C_Locomotion")

		var velocity: Vector2 = motion.velocity
		var acceleration: Vector2 = motion.acceleration
		var max_speed: Vector2 = motion.max_speed
		var direction: Vector2 = get_direction(input, top_down)

		# If the disable_move_timer is running, force direction.x to 0.
		if not motion.disable_move_timer.is_stopped():
			direction.x = 0

		if direction.x > 0:
			motion.facing = C_Locomotion.Facing.RIGHT
		elif direction.x < 0:
			motion.facing = C_Locomotion.Facing.LEFT

		acceleration += gravity
		velocity = Utils.calculate_velocity(velocity, max_speed, acceleration, delta, direction)
		velocity = e.move_and_slide(
			velocity, up_direction, stop_on_slope, max_slides, floor_max_angle, infinite_inertia
		)
		motion.was_on_floor = motion.is_on_floor
		motion.is_on_floor = e.is_on_floor()

		var friction := friction_air
		if motion.is_on_floor:
			friction = friction_ground
			# when landing, we want to disable movement for a little bit.
			if motion.was_on_floor == false:
				var fall_height: float = abs(motion.min_y - e.global_position.y)
				# 25 is a single normal jump
				# scale it up to 3x the duration
				# TODO: make these numbers not hardcoded -- should they live in locomotion system or component?
				var disable_multiplier: float = min(fall_height / 30.0, 3.0)
				motion.disable_move_timer.start(0.1 * disable_multiplier)
			motion.min_y = e.global_position.y
		else:
			# if we're in the air, record the smallest y position (smallest value, highest on the screen)
			motion.min_y = min(e.global_position.y, motion.min_y)

		# Apply FRICTION if no player input
		if direction.x == 0:
			velocity.x = lerp(velocity.x, 0, friction * delta)
			if abs(velocity.x) < 5:
				velocity.x = 0

		motion.velocity = velocity
		motion.max_speed = max_speed


static func get_direction(input: C_Input, _top_down := true) -> Vector2:
	if not input:
		return Vector2.ZERO if _top_down else Vector2(0, 1)
	var mu: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_UP) else 0
	var md: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_DOWN) else 0
	var mr: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_RIGHT) else 0
	var ml: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_LEFT) else 0
	return Vector2(mr - ml, md - mu) if _top_down else Vector2(mr - ml, 1)

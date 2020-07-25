class_name S_KinematicMotion2D
extends Node

const entity_filter : = ["KinematicBody2D"]
const system_name := "S_KinematicMotion2D"
const requirements = ["C_KinematicMotion2D"]

export var acceleration_default := Vector2(5000.0, 0.0)
export var max_speed_default := Vector2(400.0, 1200.0)
export var top_down := false
export var gravity := Vector2(0, 4000)
export var friction_air := 1.0
export var friction_ground := 20.0

# move_and_slide parameters
export var up_direction := Vector2.UP
export var stop_on_slope := true
export var max_slides := 4
export var floor_max_angle := PI / 4
export var infinite_inertia := true


func _system_init(system_manager: SystemManager) -> bool:
	return true


func _system_physics_process(entities: Array, delta: float) -> void:
	for e in entities:
		# This should never happened, but just in case...
		if not e is KinematicBody2D:
			continue
		var input: C_Input = e.get_component("C_Input")
		var motion: C_KinematicMotion2D = e.get_component("C_KinematicMotion2D")

		var velocity: Vector2 = motion.velocity
		var acceleration: Vector2 = motion.acceleration
		var max_speed: Vector2 = motion.max_speed
		var direction: Vector2 = get_direction(input, top_down)
		acceleration += gravity
		velocity = calculate_velocity(velocity, max_speed, acceleration, delta, direction)
		velocity = e.move_and_slide(
			velocity, up_direction, stop_on_slope, max_slides, floor_max_angle, infinite_inertia
		)

		var friction := friction_air
		if e.is_on_floor():
			friction = friction_ground

		# Apply FRICTION if no player input
		if direction.x == 0:
			velocity.x = lerp(velocity.x, 0, friction * delta)
			if abs(velocity.x) < 50:
				velocity.x = 0

		motion.velocity = velocity
		motion.max_speed = max_speed


static func get_direction(input: C_Input, top_down := true) -> Vector2:
	if not input:
		return Vector2.ZERO if top_down else Vector2(0, 1)
	var mu: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_UP) else 0
	var md: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_DOWN) else 0
	var mr: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_RIGHT) else 0
	var ml: int = 1 if input.is_action_pressed(Globals.InputAction.MOVE_LEFT) else 0
	return Vector2(mr - ml, md - mu) if top_down else Vector2(mr - ml, 1)

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

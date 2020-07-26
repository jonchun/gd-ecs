class_name Utils
extends Node
# Collection of static utility functions

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

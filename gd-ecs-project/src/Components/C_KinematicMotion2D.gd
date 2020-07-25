class_name C_KinematicMotion2D
extends Node

const component_name := "C_KinematicMotion2D"

export var acceleration_default := Vector2(5000.0, 0.0)
export var max_speed_default := Vector2(400.0, 1200.0)

var acceleration: Vector2
var on_floor: bool
var on_wall: bool
var velocity: Vector2
var max_speed: Vector2


func _ready() -> void:
	acceleration = acceleration_default
	max_speed = max_speed_default

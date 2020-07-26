class_name C_Locomotion
extends Node

enum Facing { LEFT, RIGHT, UP }

const component_name := "C_Locomotion"

export var acceleration_default := Vector2(1000.0, 0.0)
export var max_speed_default := Vector2(80.0, 500.0)

var acceleration: Vector2
var disable_move_timer: Timer
var facing: int = Facing.RIGHT
var is_on_floor: bool = false
var max_speed: Vector2
# tracks highest y since character entered air
var min_y: float
var velocity: Vector2
var was_on_floor: bool = false


func _init() -> void:
	disable_move_timer = Timer.new()
	disable_move_timer.one_shot = true
	add_child(disable_move_timer)


func _ready() -> void:
	acceleration = acceleration_default
	max_speed = max_speed_default

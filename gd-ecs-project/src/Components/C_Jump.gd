class_name C_Jump
extends Node

const component_name := "C_Jump"

export var jump_animation := "Jump"
export var min_jump_impulse: float = 250.0
export var max_jump_impulse: float = 350.0

var jump_count: int = 0

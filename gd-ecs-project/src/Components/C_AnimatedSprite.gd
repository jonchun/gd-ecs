class_name C_AnimatedSprite
extends AnimatedSprite

const component_name := "C_AnimatedSprite"

# This is the priority of the currently playing animation.
# Systems can check against this priority number to decide to play their animation or not
# Higher numbers take precedence over lower numbers.
var priority: int = 0

class_name S_AnimationListener
extends System
# Listens for animation action signals and plays them with priority 1 by default


func _init() -> void:
	system_name = "S_AnimationListener"
	requirements = ["C_AnimatedSprite"]


func _system_ready() -> void:
	system_manager.subscribe("play_animation", self, "play_animation")


func _system_process(entities: Array, _delta: float) -> void:
	for e in entities:
		pass


func play_animation(entity: Entity, anim_name: String, animation_priority := 0) -> void:
	if not entity.meets_requirements(requirements):
		return

	var anim_sprite: C_AnimatedSprite = entity.get_component("C_AnimatedSprite")

	# Only play animations if current animation's priority is <= this system's.
	if anim_sprite.priority <= animation_priority:
		var prev_anim := anim_sprite.animation
		var prev_frame := anim_sprite.frame
		anim_sprite.priority = animation_priority
		safe_play_animation(anim_sprite, anim_name)

		# If the new animation is non-looping, then wait for the animation_finished signal and default back to playing our previous animation.
		if (
			anim_sprite.animation == anim_name
			and not anim_sprite.frames.get_animation_loop(anim_name)
		):
			# check to make sure the priority hasn't gone up since we played the first animation and the animation hasn't changed on us
			if anim_sprite.priority <= animation_priority and anim_sprite.animation == anim_name:
				yield(anim_sprite, "animation_finished")
				anim_sprite.play(prev_anim)
				anim_sprite.frame = prev_frame
				anim_sprite.priority = 0


static func safe_play_animation(anim_sprite: AnimatedSprite, anim_name: String) -> void:
	if anim_sprite.frames.has_animation(anim_name):
		anim_sprite.play(anim_name)

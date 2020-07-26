class_name S_LocomotionAnimation
extends System

export var animation_priority := 0


func _init() -> void:
	system_name = "S_LocomotionAnimation"
	requirements = ["C_AnimatedSprite", "C_Locomotion", "C_LocomotionAnimation"]


func _system_process(entities: Array, _delta: float) -> void:
	for e in entities:
		var anim: C_LocomotionAnimation = e.get_component("C_LocomotionAnimation")
		var anim_sprite: C_AnimatedSprite = e.get_component("C_AnimatedSprite")
		var motion: C_Locomotion = e.get_component("C_Locomotion")

		match motion.facing:
			C_Locomotion.Facing.LEFT:
				anim_sprite.flip_h = true
			C_Locomotion.Facing.RIGHT:
				anim_sprite.flip_h = false
			C_Locomotion.Facing.UP:
				anim_sprite.flip_h = false
			_:
				pass

		if motion.is_on_floor:
			# changing from air -> ground, so attempt to play landing animation
			if motion.was_on_floor == false:
				system_manager.emit("play_animation", [e, anim.land_animation, 5])
			if motion.velocity.length() >= anim.run_min_speed:
				system_manager.emit("play_animation", [e, anim.run_animation, 0])
			elif motion.velocity.length() > 0:
				system_manager.emit("play_animation", [e, anim.walk_animation, 0])
			else:
				system_manager.emit("play_animation", [e, anim.idle_animation, 0])
		else:
			system_manager.emit("play_animation", [e, anim.air_animation, 0])

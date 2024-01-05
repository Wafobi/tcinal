extends CanvasLayer

signal done

func fadeIn():
	var _animationPlayer : AnimationPlayer = $AnimationPlayer
	print("playing animation fadeIn")
	_animationPlayer.play_backwards("dissolve")
	await _animationPlayer.animation_finished

func fadeOut():
	var _animationPlayer : AnimationPlayer = $AnimationPlayer
	print("playing animation fadeOut")
	_animationPlayer.play("dissolve")
	await _animationPlayer.animation_finished
	print("animation Done")
	done.emit()

func _on_animation_player_animation_finished(_anim_name):
	print("Done playing animation")

extends CanvasLayer

signal done

func fadeIn():
	var _animationPlayer : AnimationPlayer = $AnimationPlayer
	print("playing animation")
	_animationPlayer.play("dissolve")

func fadeOut():
	var _animationPlayer : AnimationPlayer = $AnimationPlayer
	print("playing animation")
	_animationPlayer.play_backwards("dissolve")

func _on_animation_player_animation_finished(_anim_name):
	print("Done playing animation")
	done.emit()

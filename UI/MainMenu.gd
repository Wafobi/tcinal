class_name MainMenu extends Control

signal new_game
signal continue_game
signal exit_game
signal toggleMusic

var inMenu : bool = false

func _ready():
	$GridContainer/HBoxContainer2/MusicButton.button_pressed = true
	if ResourceHandler.saveFileExists():
		$"GridContainer/Continue".grab_focus()
	else:
		$"GridContainer/Continue".hide()
		$"GridContainer/NewGame".grab_focus()

func _on_continue_pressed():
	hide()
	if get_tree().paused:
		get_tree().paused = false
	else:
		continue_game.emit()

func _on_new_game_pressed():
	hide()
	new_game.emit()

func _on_exit_game_pressed():
	hide()
	exit_game.emit()

func _on_music_button_toggled(toggled_on):
	toggleMusic.emit(toggled_on)

func _input(event):
	if Input.is_action_just_pressed("openMenu") and not inMenu:
		if not get_tree().paused:
			get_tree().paused = true
			$"GridContainer/NewGame".hide()
			$"GridContainer/Continue".show()
			$"GridContainer/ExitGame".show()
			$"GridContainer/Continue".grab_focus()
			get_tree().paused = true
			show()
		else:
			get_tree().paused = false
			hide()
			get_tree().paused = false

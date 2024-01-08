class_name MainMenu extends Control

signal new_game
signal continue_game

var inMenu : bool = false

var settingsMenu : SettingsMenu
var inNestedMenu = false

func _ready():
	if get_parent() is MarginContainer:
		hide
	settingsMenu = $SettingsMenu
	settingsMenu.hide()

func setFocus():
	if not get_tree().paused:
		if ResourceHandler.playerSaveFileExists():
			$"GridContainer/Continue".grab_focus()
		else:
			$"GridContainer/Continue".hide()
			$"GridContainer/NewGame".grab_focus()
	else:
		$"GridContainer/NewGame".hide()
		$"GridContainer/Continue".show()
		$"GridContainer/Continue".grab_focus()

func showMenu():
	setFocus()
	super.show()

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
	get_tree().quit()

func _input(event):
	if Input.is_action_just_pressed("Pause Game"):
		if not inMenu and not inNestedMenu:
			if not get_tree().paused:
				get_tree().paused = true
				showMenu()
			else:
				get_tree().paused = false
				hide()
		elif inNestedMenu:
			settingsMenu.hideMenu()

func _on_settings_pressed():
	inNestedMenu = true
	$GridContainer.hide()
	settingsMenu.showMenu()
	await settingsMenu.tutorial_done
	setFocus()
	inNestedMenu = false
	$GridContainer.show()

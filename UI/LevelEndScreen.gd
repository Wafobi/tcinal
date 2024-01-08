class_name LevelEndScreen extends Control

signal continuePressed

func showMenu():
	$"GridContainer/Button".grab_focus()

func _on_button_pressed():
	hide()
	continuePressed.emit()

func getLabel() -> Label:
	return $GridContainer/Label


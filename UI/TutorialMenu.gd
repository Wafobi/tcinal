class_name TutorialMenu extends Control

signal tutorial_done
# Called when the node enters the scene tree for the first time.
func _ready():
	for action in InputMap.get_actions():
		print_debug(action)
	$"GridContainer/Button".grab_focus()

#tutorial Menu
func _on_button_pressed():
	hide()
	tutorial_done.emit()

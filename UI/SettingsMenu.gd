class_name SettingsMenu extends Control

signal tutorial_done
signal remapEvent

var uiMap : Dictionary = {}

var audioPlayer : AudioStreamPlayer2D

func setAudioPlayer(inAudio : AudioStreamPlayer2D):
	audioPlayer = inAudio
	ResourceHandler.loadSettings()
	audioPlayer.set_volume_db(ResourceHandler.game_settings.volume)
	$TextureRect/GridContainer/VolumeSlider.value = ResourceHandler.game_settings.volume

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is MarginContainer:
		hide()

	$TextureRect/GridContainer/VBoxContainer/HBoxContainer2/MusicButton.button_pressed = true
	$"TextureRect/GridContainer/Use Controller".button_pressed = false
	$"TextureRect/GridContainer/PlayButton".grab_focus()
	Input.joy_connection_changed.connect(checkControllerConnection)
	checkControllerConnection()
	var blacklist : Array = ["walk_up", "walk_down", "dash"]
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action in blacklist:
			continue
		for actionEvent : InputEvent in InputMap.action_get_events(action):
			extractKeyName(action, actionEvent.as_text())
	print(controllerMapping)
	showMappings(ResourceHandler.getPlayerKeyboardMappings())

func checkControllerConnection(device: int = 0, connected: bool = false):
	if Input.get_connected_joypads().size() == 0:
		$"TextureRect/GridContainer/Use Controller".disabled = true
		$"TextureRect/GridContainer/Use Controller".text = "No Controller connected"
	else:
		$"TextureRect/GridContainer/Use Controller".disabled = false
		$"TextureRect/GridContainer/Use Controller".text = "Show Controller mappings"

func showMappings(dict : Dictionary):
	$TextureRect/GridContainer/InfoLabel.text = "KeyMapping:"
	for n in $TextureRect/GridContainer/Controls.get_children():
		$TextureRect/GridContainer/Controls.remove_child(n)
		n.queue_free()
	var keys = dict.keys()
	keys.sort()
	for mapping in keys:
		createUIElement(mapping, dict[mapping])

func showMenu():
	$"TextureRect/GridContainer/PlayButton".grab_focus()
	show()

func hideMenu():
	hide()
	tutorial_done.emit()

func addMapping(dict : Dictionary, key : String, value):
	dict[key] = value

var controllerMapping : Dictionary = {}
func extractKeyName(actionName : String, text : String):
	if text.begins_with("Joypad"):
		addMapping(controllerMapping,actionName,text)

func createUIElement(keyFunctionName : String, key : String):
	var box : HBoxContainer = HBoxContainer.new()
	var decrLabel : Label = Label.new()
	var keyButton : Button = Button.new()
	keyButton.name = keyFunctionName
	decrLabel.text = keyFunctionName+":"
	keyButton.text = key
	keyButton.pressed.connect(func(): changeMapping(keyButton))
	box.add_child(decrLabel)
	box.add_child(VSeparator.new())
	box.add_child(keyButton)
	$TextureRect/GridContainer/Controls.add_child(box)
	$TextureRect/GridContainer/Controls.move_child(box,1)

func changeMapping(button : Button):
	var keyActionName = button.name
	var key = button.text
	if InputMap.has_action(keyActionName):
		for actionEvent : InputEvent in InputMap.action_get_events(keyActionName):
			if not actionEvent.as_text().begins_with("Joypad") and not $"TextureRect/GridContainer/Use Controller".button_pressed:
				$TextureRect/GridContainer/InfoLabel.text = "KeyMapping: Press the Button you want to use for " + keyActionName
				var new_key : InputEventKey = await remapEvent
				#Check if new key was assigned somewhere
				for i in InputMap.get_actions():
					if InputMap.action_has_event(i, new_key) and not i.begins_with("ui_"):
						$TextureRect/GridContainer/InfoLabel.text = "KeyMapping : %s is already bound - try again" % new_key.as_text() 
						return
				remapKey(keyActionName, actionEvent, new_key)
				showMappings(ResourceHandler.getPlayerKeyboardMappings())
				break
			elif actionEvent.as_text().begins_with("Joypad") and $"TextureRect/GridContainer/Use Controller".button_pressed:
				$TextureRect/GridContainer/InfoLabel.text = "KeyMapping: Controller remapping currently not supported"

func remapKey(keyActionName :String , actionEvent : InputEvent, new_key : InputEventKey):
	ResourceHandler.setPlayerKeyboardMapping(keyActionName, new_key.as_text())
	InputMap.action_erase_event(keyActionName, actionEvent)
	InputMap.action_add_event(keyActionName, new_key)

#tutorial Menu
func _on_button_pressed():
	ResourceHandler.saveSettings()
	hideMenu()

func _on_use_controller_toggled(toggled_on):
	if toggled_on:
		showMappings(ResourceHandler.getPlayerControllerMappings())
	else:
		showMappings(ResourceHandler.getPlayerKeyboardMappings())

func _on_volume_slider_drag_ended(value_changed):
	if value_changed:
		ResourceHandler.game_settings.volume = $TextureRect/GridContainer/VolumeSlider.value
		audioPlayer.set_volume_db(ResourceHandler.game_settings.volume)

func _on_music_button_toggled(toggled_on):
	if audioPlayer:
		print(toggled_on)
		if toggled_on:
			audioPlayer.set_volume_db(ResourceHandler.game_settings.volume)
			audioPlayer.play()
		else:
			audioPlayer.stop()

func _unhandled_input(event):
	if event is InputEventKey:
		remapEvent.emit(event)
	elif event is InputEventJoypadButton:
		remapEvent.emit(event)

func createKeyEvent(key) -> InputEventKey:
	var assignevent = InputEventKey.new()
	(assignevent as InputEventKey).set_keycode(
			OS.find_keycode_from_string(key)
	)
	(assignevent as InputEventKey).set_pressed(true)
	return assignevent

func _on_reset_mappings_pressed():
	if not $"TextureRect/GridContainer/Use Controller".button_pressed:
		ResourceHandler.resetPlayerKeyboardMappings()
		for keyActionName in ResourceHandler.getPlayerKeyboardMappings():
			var key = ResourceHandler.getPlayerKeyboardMappings()[keyActionName]
			var new_key = createKeyEvent(key)
			var actionEvent = InputMap.action_get_events(keyActionName)[0]
			remapKey(keyActionName, actionEvent, new_key)
		showMappings(ResourceHandler.getPlayerKeyboardMappings())
	else:
		#ResourceHandler.resetControllerMappings()
		return

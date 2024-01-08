class_name SettingsMenu extends Control

signal tutorial_done

var uiMap : Dictionary = {}
var controllerMapping : Dictionary = {}
var keyboardMapping : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is MarginContainer:
		hide()
	$AudioStreamPlayer2D.playing = false
	ResourceHandler.loadSettings()
	$AudioStreamPlayer2D.set_volume_db(ResourceHandler.game_settings.volume)
	$GridContainer/VolumeSlider.value = ResourceHandler.game_settings.volume
	$AudioStreamPlayer2D.playing = true
	$GridContainer/VBoxContainer/HBoxContainer2/MusicButton.button_pressed = true
	$"GridContainer/Use Controller".button_pressed = false
	Input.joy_connection_changed.connect(checkControllerConnection)
	var blacklist : Array = ["walk_up", "walk_down", "dash"]
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action in blacklist:
			continue
		for actionEvent in InputMap.action_get_events(action):
			extractKeyName(action, actionEvent.as_text())
	checkControllerConnection()
	showMappings(keyboardMapping)

func checkControllerConnection(device: int = 0, connected: bool = false):
	if Input.get_connected_joypads().size() == 0:
		$"GridContainer/Use Controller".button_pressed = false
		$"GridContainer/Use Controller".disabled = true
		$"GridContainer/Use Controller".text = "No Controller connected"
	else:
		$"GridContainer/Use Controller".disabled = false
		$"GridContainer/Use Controller".text = "Show Controller mappings"
		$"GridContainer/Use Controller".button_pressed = connected

func showMappings(dict : Dictionary):
	for n in $GridContainer/Controls.get_children():
		$GridContainer/Controls.remove_child(n)
		n.queue_free()
	var keys = dict.keys()
	keys.sort()
	for mapping in keys:
		createUIElement(mapping, dict[mapping])

func showMenu():
	$"GridContainer/PlayButton".grab_focus()
	show()

func hideMenu():
	hide()
	tutorial_done.emit()

func addMapping(dict : Dictionary, key : String, value):
	if not dict.has(key):
		dict[key] = Array()
	dict[key].push_back(value)

func extractKeyName(actionName : String, text : String):
	print(text)
	if text.begins_with("Joypad"):
		addMapping(controllerMapping,actionName,text.split("(")[1].split(")")[0].split(",")[0])
	else:
		addMapping(keyboardMapping,actionName,text.split(" ")[0])

func createUIElement(keyFunctionName : String, keys : Array):
	var box : HBoxContainer = HBoxContainer.new()
	var decrLabel : Label = Label.new()
	var keyButton : Button = Button.new()
	
	decrLabel.text = keyFunctionName+":"
	keyButton.text = var_to_str(keys).lstrip("[\"").rstrip("\"]")
	box.add_child(decrLabel)
	box.add_child(VSeparator.new())
	box.add_child(keyButton)
	$GridContainer/Controls.add_child(box)
	$GridContainer/Controls.move_child(box,1)

func changeMapping():
	pass

#tutorial Menu
func _on_button_pressed():
	ResourceHandler.saveSettings()
	hideMenu()

func _on_use_controller_toggled(toggled_on):
	print(toggled_on)
	if toggled_on:
		showMappings(controllerMapping)
	else:
		showMappings(keyboardMapping)

func _on_volume_slider_drag_ended(value_changed):
	if value_changed:
		ResourceHandler.game_settings.volume = $GridContainer/VolumeSlider.value
		$AudioStreamPlayer2D.set_volume_db(ResourceHandler.game_settings.volume)

func _on_music_button_toggled(toggled_on):
	if toggled_on:
		$AudioStreamPlayer2D.set_volume_db(ResourceHandler.game_settings.volume)
		$AudioStreamPlayer2D.play()
	else:
		$AudioStreamPlayer2D.stop()


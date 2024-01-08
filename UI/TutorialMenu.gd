class_name TutorialMenu extends Control

signal tutorial_done
# Called when the node enters the scene tree for the first time.
func _ready():
	var blacklist : Array = ["walk_up", "walk_down", "dash"]
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action in blacklist:
			continue
		for actionEvent in InputMap.action_get_events(action):
			extractKeyName(action, actionEvent.as_text())
	var keys = keyboardMapping.keys()
	keys.sort()
	for mapping in keys:
		addMapping(uiMap, mapping, createUIElement(mapping, keyboardMapping[mapping]))

var uiMap : Dictionary = {}

func showMenu():
	$"GridContainer/PlayButton".grab_focus()
	show()

var controllerMapping : Dictionary = {}
var keyboardMapping : Dictionary = {}

func addMapping(dict : Dictionary, key : String, value):
	if not dict.has(key):
		dict[key] = Array()
	dict[key].push_back(value)

func extractKeyName(actionName : String, text : String):
	if text.begins_with("Joypad"):
		addMapping(controllerMapping,actionName,text.split("(")[1].split(")")[0].split(",")[0])
	else:
		addMapping(keyboardMapping,actionName,text.split(" ")[0])

func createUIElement(keyFunctionName : String, keys : Array) -> Label:
	var box : HBoxContainer = HBoxContainer.new()
	var decrLabel : Label = Label.new()
	var keysLabel : Label = Label.new()
	decrLabel.text = keyFunctionName+":"
	keysLabel.text = var_to_str(keys).lstrip("[").rstrip("]")
	box.add_child(decrLabel)
	box.add_child(keysLabel)
	$GridContainer.add_child(box)
	$GridContainer.move_child(box,1)
	return keysLabel

#tutorial Menu
func _on_button_pressed():
	hide()
	tutorial_done.emit()

